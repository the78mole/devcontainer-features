#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Test that all features work together
check "jmp-installed" which jmp
check "j-alias-installed" which j
check "pre-commit-installed" which pre-commit
check "uv-installed" which uv

# Test functionality
check "jmp-help" jmp --help
check "j-help" j --help
check "pre-commit-help" pre-commit --help

# Report result
reportResults
