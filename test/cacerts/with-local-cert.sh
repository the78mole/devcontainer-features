#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Check that ca-certificates and curl are installed
check "ca-certificates-installed" dpkg -s ca-certificates
check "curl-installed" bash -c "curl --version"

# Check that update-ca-certificates is available
check "update-ca-certificates-available" which update-ca-certificates

# Check that the local cert directory exists
check "cert-dir-exists" bash -c "test -d /usr/local/share/ca-certificates"

# Check that the local cert was copied (test-local-ca.pem → test-local-ca.crt)
check "local-cert-installed" bash -c "test -f /usr/local/share/ca-certificates/test-local-ca.crt"

# Check that the cert path was added to /etc/ca-certificates.conf
check "local-cert-in-conf" bash -c "grep -qF '/usr/local/share/ca-certificates/test-local-ca.crt' /etc/ca-certificates.conf"

# Check that the CA bundle was updated
check "ca-bundle-present" bash -c "test -f /etc/ssl/certs/ca-certificates.crt"

# Report result
reportResults
