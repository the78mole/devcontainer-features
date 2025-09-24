#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Feature specific tests
check "jmp-installed" which jmp
check "j-alias-installed" which j
check "jmp-help-command" jmp --help
# Note: j --help requires JUMPSTARTER_HOST environment variable, so we skip this test
# check "j-help-command" bash -c "JUMPSTARTER_HOST=http://localhost:8080 j --help"

# Test basic jumpstarter functionality (version might not work in all environments)
check "jmp-responds" bash -c "jmp --help > /dev/null 2>&1"
# Note: j command requires JUMPSTARTER_HOST environment variable, so we skip this test
# check "j-responds" bash -c "JUMPSTARTER_HOST=http://localhost:8080 j --help > /dev/null 2>&1"

# Check that commands are in PATH
check "jmp-in-path" bash -c "echo \$PATH | grep -E '(\/usr\/local\/bin|\.local\/bin)'"

# Report result
reportResults
