#!/bin/bash
set -e

URLS=${URLS:-""}

echo "Installing CA certificates feature..."

# Install required packages and set OS-specific variables
echo "📦 Installing required packages (ca-certificates, curl, openssl)..."
if command -v apt-get &>/dev/null; then
    apt-get update -y
    apt-get install -y ca-certificates curl openssl
    CERT_DIR="/usr/local/share/ca-certificates"
    CA_CONF="/etc/ca-certificates.conf"
    UPDATE_CMD="update-ca-certificates"
elif command -v apk &>/dev/null; then
    apk add --no-cache ca-certificates curl openssl
    CERT_DIR="/usr/local/share/ca-certificates"
    CA_CONF="/etc/ca-certificates.conf"
    UPDATE_CMD="update-ca-certificates"
elif command -v yum &>/dev/null; then
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

# Split comma-separated URLs and process each one
IFS=',' read -ra URL_LIST <<< "${URLS}"
INSTALLED=0

for url in "${URL_LIST[@]}"; do
    # Strip leading/trailing whitespace
    url=$(echo "${url}" | tr -d '[:space:]')
    [ -z "${url}" ] && continue

    # Derive a safe filename from the URL
    cert_filename=$(basename "${url}" | sed 's/[^a-zA-Z0-9._-]/_/g')

    # Ensure the filename ends with .crt (required by update-ca-certificates)
    case "${cert_filename}" in
        *.crt) : ;;  # already has .crt extension, no change
        *.pem) cert_filename="${cert_filename%.pem}.crt" ;;
        *) cert_filename="${cert_filename}.crt" ;;
    esac

    cert_path="${CERT_DIR}/${cert_filename}"

    echo "   Downloading: ${url}"
    if curl -fsSL --retry 3 --retry-delay 2 -o "${cert_path}" "${url}"; then
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
    else
        echo "   ❌ Failed to download: ${url}"
    fi
done

echo ""
echo "🔄 Running ${UPDATE_CMD}..."
${UPDATE_CMD}
echo ""
echo "✅ CA certificates feature installation complete! Installed ${INSTALLED} certificate(s)."
