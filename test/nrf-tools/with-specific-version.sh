#!/usr/bin/env bash
# Scenario: with-specific-version
# Tests that pinned nrfCliVersion and J-Link version are correctly installed.

set -e

source dev-container-features-test-lib

check "nrfjprog-installed"          which nrfjprog
check "nrfjprog-version-contains"   bash -c "nrfjprog --version | grep -E '10\.24\.[0-9]+'"
check "mergehex-installed"          which mergehex
check "jlinkexe-in-path"            which JLinkExe
check "jlinkgdb-in-path"            which JLinkGDBServerCLExe
check "jlink-install-dir"           bash -c "ls /opt/SEGGER/JLink/ | grep -q libjlinkarm"
check "jlink-lib-symlink"           bash -c "test -L /usr/lib/libjlinkarm.so"
check "jlink-ldconfig-loaded"       bash -c "ldconfig -p | grep -q libjlinkarm"


reportResults
