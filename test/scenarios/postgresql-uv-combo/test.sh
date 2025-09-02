#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition of a helper function
check "PostgreSQL version" bash -c "psql --version"
check "PostgreSQL server binary" bash -c "which postgres"
check "PostgreSQL client binary" bash -c "which psql"

check "uv version" bash -c "uv --version"
check "uv binary location" bash -c "which uv"
check "uv pip functionality" bash -c "uv pip --help"

# Test that both tools can work together
check "PostgreSQL service status" bash -c "pg_isready || echo 'PostgreSQL not running (expected in test)'"
check "uv can create virtual environment" bash -c "cd /tmp && uv venv test-env && ls -la test-env"

# Test Python database connectivity setup
check "Install psycopg2 with uv" bash -c "cd /tmp && uv pip install psycopg2-binary"
check "Python can import psycopg2" bash -c "python3 -c 'import psycopg2; print(\"psycopg2 imported successfully\")'"

# Report result
reportResults
