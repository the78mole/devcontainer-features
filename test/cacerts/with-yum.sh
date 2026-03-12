#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Check required packages are installed (RHEL/Fedora uses rpm)
check "ca-certificates-installed" bash -c "rpm -q ca-certificates"
check "curl-installed" bash -c "curl --version"
check "openssl-installed" bash -c "openssl version"

# Check that update-ca-trust command is available
check "update-ca-trust-available" command -v update-ca-trust

# Check that the cert trust anchor directory exists
check "cert-dir-exists" bash -c "test -d /etc/pki/ca-trust/source/anchors"

# Check that the system CA bundle is present
check "ca-bundle-present" bash -c "test -f /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem"

# Report result
reportResults
