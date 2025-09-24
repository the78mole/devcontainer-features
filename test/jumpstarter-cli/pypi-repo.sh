#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Test PyPI installation
check "jmp-installed" which jmp
check "j-alias-installed" which j
check "uv-installed" which uv

# Test functionality
check "jmp-help" jmp --help
check "j-help" j --help

# Report result
reportResults
