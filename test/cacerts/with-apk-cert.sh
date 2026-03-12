#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Check that ca-certificates and curl are installed (Alpine uses apk)
check "ca-certificates-installed" apk info -e ca-certificates
check "curl-installed" bash -c "curl --version"

# Check that update-ca-certificates is available
check "update-ca-certificates-available" command -v update-ca-certificates

# Check that the local cert directory exists
check "cert-dir-exists" bash -c "test -d /usr/local/share/ca-certificates"

# Check that the ISRG Root X1 cert was downloaded (isrgrootx1.pem → isrgrootx1.crt)
check "isrg-root-cert-downloaded" bash -c "test -f /usr/local/share/ca-certificates/isrgrootx1.crt"

# Check that the cert path was added to /etc/ca-certificates.conf
check "isrg-root-cert-in-conf" bash -c "grep -qF '/usr/local/share/ca-certificates/isrgrootx1.crt' /etc/ca-certificates.conf"

# Check that the CA bundle was updated
check "ca-bundle-present" bash -c "test -f /etc/ssl/certs/ca-certificates.crt"

# Report result
reportResults
