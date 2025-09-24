#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Test that all features work together
check "pre-commit-installed" which pre-commit
check "pre-commit-version" pre-commit --version
check "uv-installed" which uv
check "postgresql-installed" which psql

# Test pre-commit functionality
check "pre-commit-sample-config" pre-commit sample-config
check "pre-commit-help" pre-commit --help

# Report result
reportResults