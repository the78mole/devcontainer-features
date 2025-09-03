#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Test auto-start functionality - PostgreSQL should be running
check "postgresql-auto-started" bash -c "pg_isready -t 5"

# Test that the devcontainer user can connect to PostgreSQL
check "postgresql-user-can-connect" bash -c "psql -U postgres -c 'SELECT version();'"

# Test that the devcontainer user can create databases
check "postgresql-user-can-create-db" bash -c "createdb testdb && dropdb testdb"

# Test that the devcontainer user is in postgres group
check "user-in-postgres-group" bash -c "groups | grep postgres"

# Test that sudoers rules are set up correctly
check "postgresql-sudoers-setup" bash -c "test -f /etc/sudoers.d/postgresql-devcontainer"

# Report result
reportResults