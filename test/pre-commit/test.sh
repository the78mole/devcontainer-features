#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Feature specific tests
check "pre-commit-installed" which pre-commit
check "pre-commit-version-check" pre-commit --version
check "pre-commit-in-path" bash -c "echo \$PATH | grep -E '(\/usr\/local\/bin|\.local\/bin)'"
check "pre-commit-help-command" pre-commit --help

# Test basic pre-commit functionality
check "pre-commit-sample-repos" pre-commit sample-config

# Report result
reportResults