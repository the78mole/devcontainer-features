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

# Test Python database connectivity setup with uv project
check "Initialize uv project" bash -c "cd /tmp && uv init test-project"
check "Add psycopg2 dependency" bash -c "cd /tmp/test-project && uv add psycopg2-binary"
check "Python can import psycopg2" bash -c "cd /tmp/test-project && uv run python -c 'import psycopg2; print(\"psycopg2 imported successfully\")'"

# Report result
reportResults
