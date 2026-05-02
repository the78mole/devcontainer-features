#!/usr/bin/env bash
# =============================================================================
# install.sh – SEGGER J-Link Feature
#
# Steps:
#   1. EULA check (SEGGER J-Link license must be accepted)
#   2. Download J-Link .tgz from the official SEGGER server
#   3. Extract to /opt/SEGGER/JLink
#   4. Create symlinks in /usr/local/bin (JLinkExe, JLinkGDBServerCLExe,
#      JLinkRTTClient, JLinkRTTLogger)
#   5. Register libjlinkarm.so in /usr/lib/
#   6. Cleanup
#
# NOTE: udev rules (99-jlink.rules) must be installed manually on the HOST.
#       udevd has no effect inside a container.
#       Path inside the archive: /opt/SEGGER/JLink/99-jlink.rules
# =============================================================================
set -euo pipefail

JLINK_VERSION="${VERSION:-V796a}"
ACCEPT_EULA="${ACCEPTSEGGEREULA:-false}"

# ── EULA check ────────────────────────────────────────────────────────────────
if [ "${ACCEPT_EULA}" != "true" ]; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║  ERROR: SEGGER J-Link EULA not accepted                          ║"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    echo "║  Please read the EULA at:                                        ║"
    echo "║    https://www.segger.com/downloads/jlink/                       ║"
    echo "║                                                                  ║"
    echo "║  Then set in your devcontainer.json:                             ║"
    echo "║    \"acceptSeggerEula\": true                                      ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    exit 1
fi

# ── Architecture detection ────────────────────────────────────────────────────
case "$(uname -m)" in
    x86_64)
        SEGGER_ARCH="x86_64"
        ;;
    aarch64|arm64)
        SEGGER_ARCH="arm64"
        ;;
    *)
        echo "ERROR: Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
esac
echo ">>> [jlink] Detected architecture: $(uname -m) → SEGGER_ARCH=${SEGGER_ARCH}"

JLINK_INSTALL_DIR="/opt/SEGGER/JLink"

# ── Prerequisites ─────────────────────────────────────────────────────────────
echo ">>> [jlink] Updating package lists ..."
apt-get update -y -qq

if ! command -v curl &>/dev/null || ! [ -f /etc/ssl/certs/ca-certificates.crt ]; then
    echo ">>> [jlink] Installing prerequisites (curl, ca-certificates) ..."
    apt-get install -y --no-install-recommends curl ca-certificates
fi

# ── Download & install J-Link ─────────────────────────────────────────────────
JLINK_TGZ_URL="https://www.segger.com/downloads/jlink/JLink_Linux_${JLINK_VERSION}_${SEGGER_ARCH}.tgz"
TMP_TGZ="$(mktemp /tmp/jlink-XXXXXX.tgz)"
TMP_EXTRACT="$(mktemp -d /tmp/jlink-extract-XXXXXX)"

echo ">>> [jlink] Downloading J-Link ${JLINK_VERSION} (EULA accepted) ..."
curl -fsSL \
    -X POST \
    -d "accept_license_agreement=accepted" \
    -o "${TMP_TGZ}" \
    "${JLINK_TGZ_URL}"

echo ">>> [jlink] Extracting J-Link to ${JLINK_INSTALL_DIR} ..."
tar -xzf "${TMP_TGZ}" -C "${TMP_EXTRACT}"

JLINK_SRC="$(find "${TMP_EXTRACT}" -mindepth 1 -maxdepth 1 -type d | head -1)"
if [ -z "${JLINK_SRC}" ]; then
    echo "ERROR: Could not find extracted J-Link directory in ${TMP_EXTRACT}" >&2
    exit 1
fi

mkdir -p "${JLINK_INSTALL_DIR}"
cp -a "${JLINK_SRC}/." "${JLINK_INSTALL_DIR}/"
rm -rf "${TMP_EXTRACT}" "${TMP_TGZ}"

# ── Symlinks in /usr/local/bin ────────────────────────────────────────────────
echo ">>> [jlink] Creating symlinks in /usr/local/bin ..."
for tool in JLinkExe JLinkGDBServerCLExe JLinkRTTClient JLinkRTTLogger; do
    if [ -f "${JLINK_INSTALL_DIR}/${tool}" ]; then
        ln -sf "${JLINK_INSTALL_DIR}/${tool}" "/usr/local/bin/${tool}"
    else
        echo "WARNING: ${tool} not found in ${JLINK_INSTALL_DIR}, skipping symlink"
    fi
done

# ── Register libjlinkarm.so ───────────────────────────────────────────────────
echo ">>> [jlink] Registering libjlinkarm.so ..."
JLINK_SO="$(find "${JLINK_INSTALL_DIR}" -maxdepth 1 \( -type f -o -type l \) \
    -name "libjlinkarm.so*" ! -name "*_x86*" | sort | head -1)"
if [ -n "${JLINK_SO}" ]; then
    ln -sf "${JLINK_SO}" /usr/lib/libjlinkarm.so
else
    echo "ERROR: libjlinkarm.so not found in ${JLINK_INSTALL_DIR}" >&2
    exit 1
fi
ldconfig

# ── Verify ────────────────────────────────────────────────────────────────────
echo ">>> [jlink] Verifying installation ..."
JLinkExe --version 2>&1 | head -2 || true

echo ">>> [jlink] Done."
