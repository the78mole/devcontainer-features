#!/usr/bin/env bash
# Scenario: with-specific-version
# Tests that a pinned J-Link version is correctly installed.

set -e

source dev-container-features-test-lib

check "jlinkexe-in-path"          which JLinkExe
check "jlinkgdb-in-path"          which JLinkGDBServerCLExe
check "jlink-install-dir"         bash -c "ls /opt/SEGGER/JLink/ | grep -q libjlinkarm"
check "jlink-lib-symlink"         bash -c "test -L /usr/lib/libjlinkarm.so"
check "jlink-ldconfig-loaded"     bash -c "ldconfig -p | grep -q libjlinkarm"

reportResults
