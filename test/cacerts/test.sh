#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Check required packages are installed
check "ca-certificates-installed" dpkg -s ca-certificates
check "curl-installed" bash -c "curl --version"
check "openssl-installed" bash -c "openssl version"

# Check that update-ca-certificates command is available
check "update-ca-certificates-available" which update-ca-certificates

# Check that the local cert directory exists
check "cert-dir-exists" bash -c "test -d /usr/local/share/ca-certificates"

# Check that /etc/ca-certificates.conf exists
check "ca-certificates-conf-exists" bash -c "test -f /etc/ca-certificates.conf"

# Check that the system CA bundle is present
check "ca-bundle-present" bash -c "test -f /etc/ssl/certs/ca-certificates.crt"

# Report result
reportResults
