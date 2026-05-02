#!/usr/bin/env bash
# =============================================================================
# install.sh – nRF Command Line Tools + J-Link Feature
#
# Ablauf:
#   1. EULA-Prüfung (SEGGER J-Link Lizenz muss akzeptiert sein)
#   2. nrf-command-line-tools .deb von Nordic herunterladen + installieren
#   3. J-Link .tgz vom offiziellen SEGGER-Server herunterladen
#   4. Archiv nach /opt/SEGGER/JLink entpacken
#   5. Symlinks in /usr/local/bin (JLinkExe, JLinkGDBServerCLExe,
#      JLinkRTTClient, JLinkRTTLogger)
#   6. Symlink libjlinkarm.so → /usr/lib/
#   7. Cleanup
#
# HINWEIS: udev-Regeln (99-jlink.rules) müssen manuell auf dem HOST installiert
#          werden. Innerhalb eines Containers hat udevd keinen Effekt.
#          Pfad im Archiv: /opt/SEGGER/JLink/99-jlink.rules
# =============================================================================
set -euo pipefail

JLINK_VERSION="${VERSION:-V796a}"
NRF_CLI_VERSION="${NRFCLIVERSION:-10.24.2}"
ACCEPT_EULA="${ACCEPTSEGGEREULA:-false}"

# ── EULA-Prüfung ──────────────────────────────────────────────────────────────
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

# ── Architektur-Erkennung ────────────────────────────────────────────────────
case "$(uname -m)" in
    x86_64)
        SEGGER_ARCH="x86_64"
        NRF_ARCH="amd64"
        ;;
    aarch64|arm64)
        SEGGER_ARCH="arm64"
        NRF_ARCH="arm64"
        ;;
    *)
        echo "ERROR: Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
esac
echo ">>> [nrf-tools] Detected architecture: $(uname -m) → SEGGER_ARCH=${SEGGER_ARCH}, NRF_ARCH=${NRF_ARCH}"

# Nordic's blob storage uses dashes in the path segment (10.24.2 → 10-24-2)
NRF_CLI_VERSION_PATH="${NRF_CLI_VERSION//./-}"

JLINK_INSTALL_DIR="/opt/SEGGER/JLink"

# ── Paketlisten aktualisieren + Voraussetzungen sicherstellen ─────────────────
echo ">>> [nrf-tools] Updating package lists ..."
apt-get update -y -qq

_need_pkgs=0
command -v wget    &>/dev/null || _need_pkgs=1
command -v curl    &>/dev/null || _need_pkgs=1
command -v dpkg    &>/dev/null || _need_pkgs=1
[ -f /etc/ssl/certs/ca-certificates.crt ] || _need_pkgs=1
if [ "${_need_pkgs}" -eq 1 ]; then
    echo ">>> [nrf-tools] Installing prerequisites (wget, curl, ca-certificates, dpkg) ..."
    apt-get install -y --no-install-recommends wget curl ca-certificates dpkg
fi

# ── nRF Command Line Tools ────────────────────────────────────────────────────
NRF_DEB_URL="https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x/${NRF_CLI_VERSION_PATH}/nrf-command-line-tools_${NRF_CLI_VERSION}_${NRF_ARCH}.deb"
TMP_DEB="$(mktemp /tmp/nrf-cmd-tools-XXXXXX.deb)"

echo ">>> [nrf-tools] Downloading nRF Command Line Tools v${NRF_CLI_VERSION} (${NRF_ARCH}) ..."
wget -q -O "${TMP_DEB}" "${NRF_DEB_URL}"

echo ">>> [nrf-tools] Installing nrfjprog ..."
apt-get install -y --no-install-recommends libusb-1.0-0
dpkg -i "${TMP_DEB}"
rm "${TMP_DEB}"
JLINK_TGZ_URL="https://www.segger.com/downloads/jlink/JLink_Linux_${JLINK_VERSION}_${SEGGER_ARCH}.tgz"
TMP_TGZ="$(mktemp /tmp/jlink-XXXXXX.tgz)"
TMP_EXTRACT="$(mktemp -d /tmp/jlink-extract-XXXXXX)"

echo ">>> [nrf-tools] Downloading J-Link ${JLINK_VERSION} (EULA accepted) ..."
curl -fsSL \
    -X POST \
    -d "accept_license_agreement=accepted" \
    -o "${TMP_TGZ}" \
    "${JLINK_TGZ_URL}"

echo ">>> [nrf-tools] Extracting J-Link to ${JLINK_INSTALL_DIR} ..."
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
echo ">>> [nrf-tools] Creating symlinks in /usr/local/bin ..."
for tool in JLinkExe JLinkGDBServerCLExe JLinkRTTClient JLinkRTTLogger; do
    if [ -f "${JLINK_INSTALL_DIR}/${tool}" ]; then
        ln -sf "${JLINK_INSTALL_DIR}/${tool}" "/usr/local/bin/${tool}"
    else
        echo "WARNING: ${tool} not found in ${JLINK_INSTALL_DIR}, skipping symlink"
    fi
done

# ── libjlinkarm.so → /usr/lib/ ───────────────────────────────────────────────
echo ">>> [nrf-tools] Registering libjlinkarm.so ..."
JLINK_SO="$(find "${JLINK_INSTALL_DIR}" -maxdepth 1 \( -type f -o -type l \) \
    -name "libjlinkarm.so*" ! -name "*_x86*" | sort | head -1)"
if [ -n "${JLINK_SO}" ]; then
    ln -sf "${JLINK_SO}" /usr/lib/libjlinkarm.so
else
    echo "ERROR: libjlinkarm.so not found in ${JLINK_INSTALL_DIR}" >&2
    exit 1
fi
ldconfig


# ── Verifikation ──────────────────────────────────────────────────────────────
echo ">>> [nrf-tools] Verifying installation ..."
nrfjprog --version
JLinkExe --version 2>&1 | head -2 || true

echo ">>> [nrf-tools] Done."
