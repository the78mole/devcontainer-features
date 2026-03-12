#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# The feature was installed with a nonexistent URL and ignoreMissing=true.
# The installation must have succeeded (container built = exit 0).

# Check that ca-certificates and curl are installed
check "ca-certificates-installed" dpkg -s ca-certificates
check "curl-installed" bash -c "curl --version"

# Check that update-ca-certificates is available
check "update-ca-certificates-available" which update-ca-certificates

# Check that the cert directory exists (created even when no certs installed)
check "cert-dir-exists" bash -c "test -d /usr/local/share/ca-certificates"

# Check that the nonexistent cert was NOT installed
check "missing-cert-not-installed" bash -c "! test -f /usr/local/share/ca-certificates/fake-ca.crt"

# Check that the CA bundle is still present (existing store still works)
check "ca-bundle-present" bash -c "test -f /etc/ssl/certs/ca-certificates.crt"

# Report result
reportResults
