#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Test PostgreSQL latest version
check "PostgreSQL installed" bash -c "psql --version"
check "PostgreSQL binary available" bash -c "which postgres"

# Test specific uv version
check "uv version 0.8.14" bash -c "uv --version | grep '0.8.14'"
check "uv pip commands work" bash -c "uv pip list"

# Test that uv can handle Python packages for database work
check "uv can install database tools" bash -c "uv pip install --system sqlparse"
check "Python can import sqlparse" bash -c "python3 -c 'import sqlparse; print(\"Database tools available\")'"

# Verify installations don't conflict
check "Both tools accessible" bash -c "which psql && which uv"

# Report result
reportResults
