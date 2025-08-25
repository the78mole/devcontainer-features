#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Version specific tests
check "postgresql-version-16" psql --version | grep "16"
check "postgresql-config-exists" ls /etc/postgresql | grep "16"
check "postgresql-client-version-16" psql --version | grep "16"

# Report result
reportResults
