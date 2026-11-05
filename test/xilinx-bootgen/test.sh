#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "bootgen-installed" which bootgen
check "bootgen-package-installed" dpkg -s xilinx-bootgen
check "bootgen-help" bash -c "bootgen -help 2>&1 | grep -q 'Xilinx Bootgen'"

reportResults
