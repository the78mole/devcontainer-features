#!/usr/bin/env bash

PG_VERSION=${VERSION:-"latest"}
PG_ARCHIVE_ARCHITECTURES="amd64 arm64 i386 ppc64el"
PG_ARCHIVE_VERSION_CODENAMES="bookworm bullseye buster sid trixie bionic focal jammy kinetic noble"
USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"

# Default: Exit on any failure.
set -e

# Clean up
rm -rf /var/lib/apt/lists/*

# Setup STDERR.
err() {
    echo "(!) $*" >&2
}

if [ "$(id -u)" -ne 0 ]; then
    err 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u "${USERNAME}" > /dev/null 2>&1; then
    USERNAME=root
fi

apt_get_update()
{
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

# Create symlinks for PostgreSQL binaries to make them available in PATH
create_pg_symlinks() {
    local version_major=$1
    local pg_bin_dir="/usr/lib/postgresql/${version_major}/bin"

    if [ -d "${pg_bin_dir}" ]; then
        echo "Creating symlinks for PostgreSQL ${version_major} binaries..."

        # Create symlinks for all PostgreSQL binaries
        for binary in "${pg_bin_dir}"/*; do
            if [ -f "${binary}" ] && [ -x "${binary}" ]; then
                binary_name=$(basename "${binary}")
                # Create symlink in /usr/local/bin (which is typically in PATH)
                ln -sf "${binary}" "/usr/local/bin/${binary_name}"
                echo "  Created symlink: /usr/local/bin/${binary_name} -> ${binary}"
            fi
        done
    else
        echo "Warning: PostgreSQL binary directory ${pg_bin_dir} not found"
    fi
}

setup_pq() {
    local version_major=$1

    tee /usr/local/share/pq-init.sh << EOF
#!/bin/sh
set -e

version_major=\$(psql --version | sed -z "s/psql (PostgreSQL) //g" | grep -Eo -m 1 "^([0-9]+)" | sed -z "s/-//g")

echo "listen_addresses = '*'" >> /etc/postgresql/\${version_major}/main/postgresql.conf \\
    && echo "data_directory = '\$PGDATA'" >> /etc/postgresql/\${version_major}/main/postgresql.conf \\
    && echo "host   all all 0.0.0.0/0        trust" > /etc/postgresql/\${version_major}/main/pg_hba.conf \\
    && echo "host   all all ::/0             trust" >> /etc/postgresql/\${version_major}/main/pg_hba.conf \\
    && echo "host   all all ::1/128          trust" >> /etc/postgresql/\${version_major}/main/pg_hba.conf

if [ ! -f "\$PGDATA/PG_VERSION" ]; then
    echo "Initializing PostgreSQL database..."
    chown -R postgres:postgres \$PGDATA \\
        && chmod 0750 \$PGDATA \\
        && sudo -H -u postgres sh -c "/usr/lib/postgresql/\${version_major}/bin/initdb -D \$PGDATA --auth-local trust --auth-host scram-sha-256"
else
    echo "PostgreSQL database already initialized, skipping initialization"
fi

echo "Starting PostgreSQL..."
sudo /etc/init.d/postgresql start \\
    && pg_isready -t 60

set +e

# Execute whatever commands were passed in (if any). This allows us
# to set this script to ENTRYPOINT while still executing the default CMD.
exec "\$@"
EOF
    chmod +x /usr/local/share/pq-init.sh \
        && chown "${USERNAME}":root /usr/local/share/pq-init.sh
}

install_using_apt() {
    # Install dependencies
    check_packages apt-transport-https curl ca-certificates gnupg2 dirmngr sudo

    # Import the repository signing key
    curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor --output /usr/share/keyrings/pgdg-archive-keyring.gpg
     # Create the file repository configuration
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pgdg-archive-keyring.gpg]  http://apt.postgresql.org/pub/repos/apt ${VERSION_CODENAME}-pgdg main" > /etc/apt/sources.list.d/pgdg.list

    # Update lists
    apt-get update -yq

    # Soft version matching for CLI
    if [ "${PG_VERSION}" = "latest" ] || [ "${PG_VERSION}" = "lts" ] || [ "${PG_VERSION}" = "stable" ]; then
        # Empty, meaning grab whatever "latest" is in apt repo
        version_major=""
        version_suffix=""
    else
        version_major="-$(echo "${PG_VERSION}" | grep -oE -m 1 "^([0-9]+)")"
        version_suffix="=$(apt-cache show postgresql"${version_major}" | awk -F"Version: " '{print $2}' | grep -E -m 1 "^(${PG_VERSION})(\.|$|\+.*|-.*)")"

        if [ -z "${version_suffix}" ] || [ "${version_suffix}" = "=" ]; then
            echo "Provided PG_VERSION (${PG_VERSION}) was not found in the apt-cache for this package+distribution combo";
            return 1
        fi
        echo "version_major ${version_major}"
        echo "version_suffix ${version_suffix}"
    fi

    (apt-get install -yq postgresql"${version_major}""${version_suffix}" postgresql-client"${version_major}" \
        && installed_version=$(dpkg -l | grep "^ii  postgresql-[0-9]" | awk '{print $2}' | sed 's/postgresql-//' | head -n1) \
        && create_pg_symlinks "${installed_version}" \
        && setup_pq "${installed_version}") || return 1
}

export DEBIAN_FRONTEND=noninteractive

# Source /etc/os-release to get OS info
. /etc/os-release
architecture="$(dpkg --print-architecture)"

if [[ "${PG_ARCHIVE_ARCHITECTURES}" = *"${architecture}"* ]] && [[  "${PG_ARCHIVE_VERSION_CODENAMES}" = *"${VERSION_CODENAME}"* ]]; then
    install_using_apt
else
    echo "Unsupported architecture (${architecture}) or version codename (${VERSION_CODENAME})"
    exit 1
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "PostgreSQL installation completed successfully!"
echo "You can start PostgreSQL with: sudo /usr/local/share/pq-init.sh"
echo "Connect to PostgreSQL with: psql -U postgres"
