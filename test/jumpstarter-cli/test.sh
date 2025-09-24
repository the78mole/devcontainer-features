#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Feature specific tests
check "jmp-installed" which jmp
check "j-alias-installed" which j
check "jmp-help-command" jmp --help
check "j-help-command" j --help

# Test basic jumpstarter functionality (version might not work in all environments)
check "jmp-responds" bash -c "jmp --help > /dev/null 2>&1"
check "j-responds" bash -c "j --help > /dev/null 2>&1"

# Check that commands are in PATH
check "jmp-in-path" bash -c "echo \$PATH | grep -E '(\/usr\/local\/bin|\.local\/bin)'"

# Report result
reportResults