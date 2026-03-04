#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Check required packages are installed (Alpine uses apk)
check "ca-certificates-installed" apk info -e ca-certificates
check "curl-installed" bash -c "curl --version"
check "openssl-installed" bash -c "openssl version"

# Check that update-ca-certificates command is available
check "update-ca-certificates-available" which update-ca-certificates

# Check that the local cert directory exists
check "cert-dir-exists" bash -c "test -d /usr/local/share/ca-certificates"

# Check that the system CA bundle is present
check "ca-bundle-present" bash -c "test -f /etc/ssl/certs/ca-certificates.crt"

# Report result
reportResults
