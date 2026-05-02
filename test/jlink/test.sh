#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

# ── J-Link CLI tools ──────────────────────────────────────────────────────────
check "jlinkexe-in-path"          which JLinkExe
check "jlinkgdb-in-path"          which JLinkGDBServerCLExe
check "jlinkrttclient-in-path"    which JLinkRTTClient
check "jlinkrttlogger-in-path"    which JLinkRTTLogger

# ── J-Link installation ───────────────────────────────────────────────────────
check "jlink-install-dir"         bash -c "ls /opt/SEGGER/JLink/ | grep -q libjlinkarm"
check "jlink-lib-symlink"         bash -c "test -L /usr/lib/libjlinkarm.so"
check "jlink-ldconfig-loaded"     bash -c "ldconfig -p | grep -q libjlinkarm"
check "jlink-udev-rules-present"  bash -c "test -f /opt/SEGGER/JLink/99-jlink.rules"

# ── nRF tools must NOT be present ────────────────────────────────────────────
check "nrfjprog-not-installed"    bash -c "! command -v nrfjprog"

reportResults
