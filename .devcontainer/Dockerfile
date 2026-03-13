FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# ... (dein bisheriger Code: Zertifikate kopieren & update-ca-certificates)

# Setze die Variable für Node.js (wird von npm genutzt)
# Das File /etc/ssl/certs/ca-certificates.crt enthält alle Zertifikate inklusive deiner neuen
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && mkdir -p /usr/local/share/ca-certificates/ \
    && rm -rf /var/lib/apt/lists/*

COPY certs/ /usr/local/share/ca-certificates/
