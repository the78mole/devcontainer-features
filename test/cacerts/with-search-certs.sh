#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Check that required packages are installed
check "ca-certificates-installed" dpkg -s ca-certificates
check "curl-installed" bash -c "curl --version"

# Check that update-ca-certificates is available
check "update-ca-certificates-available" which update-ca-certificates

# Check that the local cert directory exists
check "cert-dir-exists" bash -c "test -d /usr/local/share/ca-certificates"

# Check that the CA bundle was updated (feature ran to completion)
check "ca-bundle-present" bash -c "test -f /etc/ssl/certs/ca-certificates.crt"

# The nonexistent search dir should not have been created (ignoreMissing=true handled it)
check "nonexistent-dir-not-created" bash -c "! test -d /nonexistent/search-dir"

# Report result
reportResults
