#!/bin/sh
set -e

# Installs bootgen from the Debian/Ubuntu package "xilinx-bootgen".

VERSION=${VERSION:-"latest"}
PACKAGE="xilinx-bootgen"

echo "Installing Xilinx bootgen (${PACKAGE}, version: ${VERSION})..."

if [ "$(id -u)" -ne 0 ]; then
    echo "❌ This script must be run as root." >&2
    exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
    echo "❌ apt-get not found. This feature only supports Debian and Ubuntu based images." >&2
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update -y

if ! apt-cache show "${PACKAGE}" >/dev/null 2>&1; then
    echo "❌ Package '${PACKAGE}' is not available in the configured apt repositories." >&2
    exit 1
fi

if [ "${VERSION}" = "latest" ]; then
    apt-get install -y --no-install-recommends "${PACKAGE}"
else
    apt-get install -y --no-install-recommends "${PACKAGE}=${VERSION}"
fi

rm -rf /var/lib/apt/lists/*

if ! command -v bootgen >/dev/null 2>&1; then
    echo "❌ bootgen installation failed: binary not found in PATH." >&2
    exit 1
fi

echo "✅ bootgen installed: $(dpkg-query -W -f='${Version}' "${PACKAGE}") ($(command -v bootgen))"
