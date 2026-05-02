#!/usr/bin/env bash
# Scenario: with-custom-jlink-dir
# NOTE: The jlinkLibDir option was removed in v1.1.0.
#       J-Link is now always installed to /opt/SEGGER/JLink via the official
#       SEGGER .tgz archive. This file is kept for reference only and is no
#       longer listed in scenarios.json.

set -e

source dev-container-features-test-lib

check "nrfjprog-installed"    which nrfjprog
check "jlinkexe-in-path"      which JLinkExe
check "jlink-install-dir"     bash -c "ls /opt/SEGGER/JLink/ | grep -q libjlinkarm"
check "jlink-lib-symlink"     bash -c "test -L /usr/lib/libjlinkarm.so"

reportResults
