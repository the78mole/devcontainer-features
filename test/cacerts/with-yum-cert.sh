#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Check that ca-certificates and curl are installed (RHEL/Fedora uses rpm)
check "ca-certificates-installed" bash -c "rpm -q ca-certificates"
check "curl-installed" bash -c "curl --version"

# Check that update-ca-trust is available
check "update-ca-trust-available" command -v update-ca-trust

# Check that the cert trust anchor directory exists
check "cert-dir-exists" bash -c "test -d /etc/pki/ca-trust/source/anchors"

# Check that the ISRG Root X1 cert was downloaded (isrgrootx1.pem → isrgrootx1.crt)
check "isrg-root-cert-downloaded" bash -c "test -f /etc/pki/ca-trust/source/anchors/isrgrootx1.crt"

# Check that the CA bundle was updated
check "ca-bundle-present" bash -c "test -f /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem"

# Report result
reportResults
