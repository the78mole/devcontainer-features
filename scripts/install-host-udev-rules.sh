#!/usr/bin/env bash
# =============================================================================
# install-host-udev-rules.sh
#
# Installiert die SEGGER J-Link udev-Regeln auf dem HOST-System.
#
# Das Skript sucht automatisch nach dem laufenden Devcontainer (anhand des
# aktuellen Arbeitsverzeichnisses), extrahiert die Regeldatei aus dem
# Container und kopiert sie nach /etc/udev/rules.d/.
#
# Verwendung (auf dem HOST ausführen, nicht im Container):
#   bash scripts/install-host-udev-rules.sh
#
# Alternativ mit explizitem Container-Namen:
#   CONTAINER=my_container bash scripts/install-host-udev-rules.sh
# =============================================================================
set -euo pipefail

RULES_SRC="/opt/SEGGER/JLink/99-jlink.rules"
RULES_DST="/etc/udev/rules.d/99-jlink.rules"

# ── Container ermitteln ───────────────────────────────────────────────────────
if [ -n "${CONTAINER:-}" ]; then
    echo ">>> Verwende angegebenen Container: ${CONTAINER}"
else
    # Suche nach einem Container, dessen Label auf das aktuelle Verzeichnis zeigt
    WORKSPACE_PATH="$(pwd)"
    CONTAINER="$(docker ps \
        --filter "label=devcontainer.local_folder=${WORKSPACE_PATH}" \
        --format "{{.Names}}" | head -1)"

    if [ -z "${CONTAINER}" ]; then
        # Fallback: Container mit passendem Image-Label suchen
        CONTAINER="$(docker ps \
            --filter "label=devcontainer.config_file" \
            --format "{{.Names}}" | head -1)"
    fi

    if [ -z "${CONTAINER}" ]; then
        echo ""
        echo "FEHLER: Kein laufender Devcontainer gefunden."
        echo ""
        echo "Mögliche Abhilfen:"
        echo "  1. Devcontainer starten (VS Code: 'Reopen in Container')"
        echo "  2. Container-Namen explizit angeben:"
        echo "       CONTAINER=<name> bash scripts/install-host-udev-rules.sh"
        echo "  3. Regeln manuell kopieren:"
        echo "       docker exec <name> cat ${RULES_SRC} | sudo tee ${RULES_DST}"
        echo ""
        exit 1
    fi

    echo ">>> Gefundener Devcontainer: ${CONTAINER}"
fi

# ── Prüfen ob die Quelldatei im Container existiert ───────────────────────────
if ! docker exec "${CONTAINER}" test -f "${RULES_SRC}" 2>/dev/null; then
    echo ""
    echo "FEHLER: ${RULES_SRC} nicht im Container '${CONTAINER}' gefunden."
    echo "Stelle sicher, dass das nrf-tools Feature korrekt installiert wurde."
    echo ""
    exit 1
fi

# ── Regeln extrahieren und installieren ───────────────────────────────────────
echo ">>> Extrahiere ${RULES_SRC} aus Container '${CONTAINER}' ..."
TMP_RULES="$(mktemp /tmp/99-jlink-XXXXXX.rules)"
docker exec "${CONTAINER}" cat "${RULES_SRC}" > "${TMP_RULES}"

echo ">>> Installiere Regeln nach ${RULES_DST} (sudo erforderlich) ..."
sudo install -m 0644 "${TMP_RULES}" "${RULES_DST}"
rm "${TMP_RULES}"

echo ">>> Lade udev-Regeln neu ..."
sudo udevadm control --reload-rules
sudo udevadm trigger

echo ""
echo "Fertig. J-Link USB-Geräte sind jetzt ohne root-Rechte zugänglich."
echo "Falls das Gerät bereits angesteckt ist, bitte ab- und neu anstecken."
