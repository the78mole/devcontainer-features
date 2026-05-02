#!/bin/bash
set -e

# Install devcontainers CLI
npm install -g @devcontainers/cli

# Authenticate gh CLI using token written by initializeCommand
TOKEN_FILE="/tmp/.gh_devcontainer_token"
if [ -f "$TOKEN_FILE" ]; then
    gh auth login --with-token < "$TOKEN_FILE"
    rm -f "$TOKEN_FILE"
fi

# Configure git user from environment variables (passed from host via devcontainer.json)
if [ -n "${GIT_AUTHOR_NAME}" ]; then
    git config --global user.name "${GIT_AUTHOR_NAME}"
fi
if [ -n "${GIT_AUTHOR_EMAIL}" ]; then
    git config --global user.email "${GIT_AUTHOR_EMAIL}"
fi

# Install cocogitto (cog) via pre-built binary
COG_VERSION="6.0.1"

ARCH=$(uname -m)
case "${ARCH}" in
    x86_64)        BIN_ARCH="x86_64" ;;
    aarch64|arm64) BIN_ARCH="aarch64" ;;
    *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

URL="https://github.com/cocogitto/cocogitto/releases/download/${COG_VERSION}/cocogitto-${COG_VERSION}-${BIN_ARCH}-unknown-linux-musl.tar.gz"

echo "Downloading cocogitto ${COG_VERSION} for ${BIN_ARCH}..."
TMPDIR=$(mktemp -d)
curl -sSL "${URL}" | tar -xz -C "${TMPDIR}"
sudo mv "${TMPDIR}/${BIN_ARCH}-unknown-linux-musl/cog" /usr/local/bin/cog
sudo chmod +x /usr/local/bin/cog
rm -rf "${TMPDIR}"
echo "Cocogitto successfully installed!"
