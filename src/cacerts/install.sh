#!/bin/sh
set -e

URLS=${URLS:-""}
IGNOREMISSING=${IGNOREMISSING:-"false"}
SEARCHCERTS=${SEARCHCERTS:-"false"}

echo "Installing CA certificates feature..."

# Install required packages and set OS-specific variables
echo "📦 Installing required packages (ca-certificates, curl, openssl)..."
if command -v apt-get >/dev/null 2>&1; then
    apt-get update -y
    apt-get install -y ca-certificates curl openssl
    CERT_DIR="/usr/local/share/ca-certificates"
    CA_CONF="/etc/ca-certificates.conf"
    UPDATE_CMD="update-ca-certificates"
elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache ca-certificates curl openssl bash
    CERT_DIR="/usr/local/share/ca-certificates"
    CA_CONF="/etc/ca-certificates.conf"
    UPDATE_CMD="update-ca-certificates"
elif command -v yum >/dev/null 2>&1; then
    yum install -y ca-certificates curl openssl
    CERT_DIR="/etc/pki/ca-trust/source/anchors"
    CA_CONF=""
    UPDATE_CMD="update-ca-trust"
else
    echo "❌ Unsupported package manager. Please install ca-certificates, curl and openssl manually."
    exit 1
fi
echo "✅ Required packages installed"

# Ensure the local cert directory exists
mkdir -p "${CERT_DIR}"

# If no URLs provided, just update the cert store and exit
if [ -z "${URLS}" ]; then
    echo "ℹ️  No URLs provided. Running ${UPDATE_CMD} with existing certs..."
    ${UPDATE_CMD}
    echo "✅ CA certificate store updated"
    exit 0
fi

echo "📜 Processing CA certificate URLs..."

INSTALLED=0
remaining="${URLS}"

# Iterate over comma-separated URLs/paths (POSIX sh compatible)
while [ -n "${remaining}" ]; do
    case "${remaining}" in
        *,*)
            entry="${remaining%%,*}"
            remaining="${remaining#*,}"
            ;;
        *)
            entry="${remaining}"
            remaining=""
            ;;
    esac

    # Strip leading/trailing whitespace
    entry=$(echo "${entry}" | tr -d '[:space:]')
    [ -z "${entry}" ] && continue

    # If searchCerts is enabled and entry is a local directory, scan it for cert files
    if [ "${SEARCHCERTS}" = "true" ]; then
        case "${entry}" in
            http://*|https://*|ftp://*)
                : # URL — fall through to normal download handling
                ;;
            *)
                if [ -d "${entry}" ]; then
                    echo "   🔍 Scanning directory: ${entry}"
                    _scan_tmp=$(mktemp)
                    find "${entry}" -maxdepth 1 -type f \( -name "*.crt" -o -name "*.pem" \) \
                        > "${_scan_tmp}" 2>/dev/null || true
                    if [ ! -s "${_scan_tmp}" ]; then
                        echo "   ⚠️  No certificate files found in: ${entry}"
                        rm -f "${_scan_tmp}"
                        continue
                    fi
                    while IFS= read -r cert_file; do
                        cf_name=$(basename "${cert_file}" | sed 's/[^a-zA-Z0-9._-]/_/g')
                        case "${cf_name}" in
                            *.crt) : ;;
                            *.pem) cf_name="${cf_name%.pem}.crt" ;;
                            *) cf_name="${cf_name}.crt" ;;
                        esac
                        cf_path="${CERT_DIR}/${cf_name}"
                        echo "   Copying: ${cert_file}"
                        cp "${cert_file}" "${cf_path}"
                        echo "   ✅ Saved to: ${cf_path}"
                        if [ -n "${CA_CONF}" ]; then
                            if ! grep -qxF "${cf_path}" "${CA_CONF}" 2>/dev/null; then
                                echo "${cf_path}" >> "${CA_CONF}"
                                echo "   📝 Added to ${CA_CONF}"
                            else
                                echo "   ℹ️  Already present in ${CA_CONF}"
                            fi
                        fi
                        INSTALLED=$((INSTALLED + 1))
                    done < "${_scan_tmp}"
                    rm -f "${_scan_tmp}"
                    continue
                elif [ ! -f "${entry}" ]; then
                    echo "   ❌ Path not found (searchCerts=true): ${entry}"
                    if [ "${IGNOREMISSING}" = "true" ]; then
                        echo "   ⚠️  Skipping (ignoreMissing=true)"
                        continue
                    else
                        exit 1
                    fi
                fi
                ;;
        esac
    fi

    # Derive a safe filename from the URL or path
    cert_filename=$(basename "${entry}" | sed 's/[^a-zA-Z0-9._-]/_/g')

    # Ensure the filename ends with .crt (required by update-ca-certificates)
    case "${cert_filename}" in
        *.crt) : ;;  # already has .crt extension, no change
        *.pem) cert_filename="${cert_filename%.pem}.crt" ;;
        *) cert_filename="${cert_filename}.crt" ;;
    esac

    cert_path="${CERT_DIR}/${cert_filename}"

    # Determine whether this is a URL or a local file path
    case "${entry}" in
        http://*|https://*|ftp://*)
            echo "   Downloading: ${entry}"
            if ! curl -fsSL --retry 3 --retry-delay 2 -o "${cert_path}" "${entry}"; then
                echo "   ❌ Failed to download: ${entry}"
                if [ "${IGNOREMISSING}" = "true" ]; then
                    echo "   ⚠️  Skipping (ignoreMissing=true)"
                    continue
                else
                    exit 1
                fi
            fi
            ;;
        *)
            echo "   Copying local file: ${entry}"
            if [ ! -f "${entry}" ]; then
                echo "   ❌ Local file not found: ${entry}"
                if [ "${IGNOREMISSING}" = "true" ]; then
                    echo "   ⚠️  Skipping (ignoreMissing=true)"
                    continue
                else
                    exit 1
                fi
            fi
            cp "${entry}" "${cert_path}"
            ;;
    esac

    echo "   ✅ Saved to: ${cert_path}"

    # Add entry to /etc/ca-certificates.conf if applicable (Debian/Alpine)
    if [ -n "${CA_CONF}" ]; then
        conf_entry="${cert_path}"
        if ! grep -qxF "${conf_entry}" "${CA_CONF}" 2>/dev/null; then
            echo "${conf_entry}" >> "${CA_CONF}"
            echo "   📝 Added to ${CA_CONF}"
        else
            echo "   ℹ️  Already present in ${CA_CONF}"
        fi
    fi

    INSTALLED=$((INSTALLED + 1))
done

echo ""
echo "🔄 Running ${UPDATE_CMD}..."
${UPDATE_CMD}
echo ""
echo "✅ CA certificates feature installation complete! Installed ${INSTALLED} certificate(s)."
