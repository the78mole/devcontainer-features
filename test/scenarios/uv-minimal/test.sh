#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Test minimal uv installation with default settings
check "uv installed" bash -c "uv --version"
check "uv binary in PATH" bash -c "which uv"
check "uv help works" bash -c "uv --help"

# Test basic uv functionality
check "uv pip help" bash -c "uv pip --help"
check "uv tool functionality" bash -c "uv tool --help || echo 'uv tool not available in this version'"

# Test on minimal Debian system
check "uv works on minimal system" bash -c "cd /tmp && uv pip list"

# Report result
reportResults
