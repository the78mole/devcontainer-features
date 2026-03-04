# CA Certificates (cacerts)

This DevContainer feature downloads CA certificates from given URLs and installs
them into the system trust store.

## Options

| Option | Type   | Default | Description                                                         |
| ------ | ------ | ------- | ------------------------------------------------------------------- |
| urls   | string | `""`    | Comma-separated list of URLs pointing to CA certificates to install |

## Usage

### Single certificate

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/cacerts": {
      "urls": "https://example.com/my-corporate-ca.pem"
    }
  }
}
```

### Multiple certificates

Multiple URLs — including both `.pem` and `.crt` extensions — can be passed as
a comma-separated list:

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/cacerts": {
      "urls": "https://example.com/root-ca.crt,https://example.com/intermediate-ca.pem,https://example.com/issuing-ca.crt"
    }
  }
}
```

### No URLs (refresh only)

When `urls` is left empty the feature still ensures that `ca-certificates`,
`curl`, and `openssl` are installed and runs the appropriate update command to
refresh the trust store:

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/cacerts": {}
  }
}
```

## What's Installed

- `ca-certificates` — system CA certificate bundle
- `curl` — used to download certificates
- `openssl` — SSL/TLS toolkit

For every URL provided the feature will:

1. Download the certificate to the OS-specific cert directory with a `.crt`
   extension (`.pem` → `.crt` renaming is applied automatically).
2. On Debian/Alpine: register the certificate path in `/etc/ca-certificates.conf`
   (if not already present).
3. Run the OS-specific trust-store update command.

### OS-specific paths

| Package manager | Cert directory                      | Update command           |
| --------------- | ----------------------------------- | ------------------------ |
| `apt-get`       | `/usr/local/share/ca-certificates/` | `update-ca-certificates` |
| `apk`           | `/usr/local/share/ca-certificates/` | `update-ca-certificates` |
| `yum`           | `/etc/pki/ca-trust/source/anchors/` | `update-ca-trust`        |

## Supported certificate file extensions

| Extension | Behaviour                                   |
| --------- | ------------------------------------------- |
| `.crt`    | Used as-is — filename is kept unchanged     |
| `.pem`    | Extension is replaced with `.crt`           |
| other     | `.crt` is appended to the original filename |

> **Note:** Certificates must be in PEM (Base64) format.
> DER-encoded binaries are not automatically converted.

## Notes

- This feature supports `apt-get` (Debian/Ubuntu), `apk` (Alpine), and `yum`
  (RHEL/CentOS) based images.
- Certificate filenames are sanitised — any characters outside
  `[a-zA-Z0-9._-]` are replaced with `_`.
- Running the feature without any URLs is safe and simply ensures the system
  CA store is up to date.
