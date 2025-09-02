#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Feature specific tests
check "uv-installed" which uv
check "uv-version-check" uv --version
check "uv-in-path" bash -c "echo \$PATH | grep '/usr/local/bin'"
check "uv-executable-permissions" bash -c "ls -la /usr/local/bin/uv | grep '^-rwxr-xr-x'"
check "uv-help-command" uv --help

# Test basic uv functionality
check "uv-pip-command" bash -c "uv pip --help"
check "uv-init-command" bash -c "uv init --help"

# Report result
reportResults
