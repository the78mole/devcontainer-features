#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Feature specific tests
check "postgresql-client-installed" which psql
check "postgresql-server-installed" which postgres
check "pq-init-script-exists" bash -c "ls /usr/local/share/pq-init.sh"
check "pgdata-env-set" bash -c "echo \$PGDATA | grep '/var/lib/postgresql/data'"

# Report result
reportResults
