#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

check "uv version" bash -c "uv --version"
check "uv binary location" bash -c "which uv"
check "uv pip functionality" bash -c "uv pip --help"

# Test Python database connectivity setup with virtual environment
check "Install psycopg2 with uv" bash -c "cd /tmp && uv venv test-env && source test-env/bin/activate && uv pip install psycopg2-binary"
check "Python can import psycopg2" bash -c "cd /tmp && source test-env/bin/activate && python -c 'import psycopg2; print(\"psycopg2 imported successfully\")'"

# Report result
reportResults
