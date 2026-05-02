#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# ── nRF CLI binaries ──────────────────────────────────────────────────────────
check "nrfjprog-installed"        which nrfjprog
check "nrfjprog-version"          nrfjprog --version
check "mergehex-installed"        which mergehex
check "mergehex-version"          mergehex --version

# ── J-Link CLI tools ──────────────────────────────────────────────────────────
check "jlinkexe-in-path"          which JLinkExe
check "jlinkgdb-in-path"          which JLinkGDBServerCLExe
check "jlinkrttclient-in-path"    which JLinkRTTClient
check "jlinkrttlogger-in-path"    which JLinkRTTLogger

# ── J-Link installation ───────────────────────────────────────────────────────
check "jlink-install-dir"         bash -c "ls /opt/SEGGER/JLink/ | grep -q libjlinkarm"
check "jlink-lib-symlink"         bash -c "test -L /usr/lib/libjlinkarm.so"
check "jlink-ldconfig-loaded"     bash -c "ldconfig -p | grep -q libjlinkarm"

# ── Basic sanity ──────────────────────────────────────────────────────────────
check "nrfjprog-in-path"          bash -c "echo \$PATH | grep -E '(/usr/bin|/usr/local/bin)'"

# Report result
reportResults
