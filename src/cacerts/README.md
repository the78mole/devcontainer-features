# CA Certificates (cacerts)

This DevContainer feature installs CA certificates from URLs or local file paths
into the system trust store.

## Options

| Option        | Type    | Default | Description                                                                             |
| ------------- | ------- | ------- | --------------------------------------------------------------------------------------- |
| urls          | string  | `""`    | Comma-separated list of URLs or absolute local file paths to CA certificates to install |
| ignoreMissing | boolean | `false` | When `true`, skip certificates that cannot be downloaded or found instead of failing    |
| searchCerts   | boolean | `false` | When `true`, treat each local directory entry in `urls` as a directory to scan for `*.crt` / `*.pem` certificate files and install all of them |

## Usage

### Single certificate (URL)

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/cacerts": {
      "urls": "https://example.com/my-corporate-ca.pem"
    }
  }
}
```

### Local file path

Absolute paths to files already present in the container image are supported:

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/cacerts": {
      "urls": "/usr/local/share/custom-certs/corporate-ca.crt"
    }
  }
}
```

### Multiple certificates (mixed URLs and local paths)

Multiple entries — including both URLs and local file paths — can be passed as
a comma-separated list:

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/cacerts": {
      "urls": "https://example.com/root-ca.crt,/opt/certs/intermediate-ca.pem,https://example.com/issuing-ca.crt"
    }
  }
}
```

### Skip missing certificates

When `ignoreMissing` is `true`, certificates that cannot be downloaded or found
on the filesystem are silently skipped instead of aborting the installation:

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/cacerts": {
      "urls": "https://optional-internal-ca.corp/root.pem",
      "ignoreMissing": true
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

### Scan a mounted certificate directory

When `searchCerts` is `true`, each local path in `urls` that resolves to a
directory at feature-installation time is scanned for `*.crt` and `*.pem`
files. Every certificate found is installed into the system trust store.

This is especially useful when you mount a workspace-local directory containing
your organisation's CA certificates into the container:

```json
// .devcontainer/devcontainer.json
{
  "name": "My project with custom certs",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/the78mole/devcontainer-features/cacerts:1": {
      "urls": "/usr/local/share/ca-certificates/local-certs",
      "searchCerts": true,
      "ignoreMissing": true
    }
  },
  "mounts": [
    "source=${localWorkspaceFolder}/.devcontainer/certs,target=/usr/local/share/ca-certificates/local-certs,type=bind,consistency=cached"
  ]
}
```

> **Note:** DevContainer feature scripts run during the image-build phase,
> *before* bind mounts are applied. If the target directory does not yet exist
> at build time (e.g. when using `mounts`), set `ignoreMissing: true` so the
> build does not fail.
>
> You have two options to make the certificates available to the trust store:
>
> 1. **Build-time only** — bake the certificates into the image or copy them in
>    a custom `Dockerfile` step *before* the feature runs. `searchCerts: true`
>    will then find and install them at build time.
>
> 2. **Runtime mount + post-create hook** — use `mounts` to bind-mount your
>    cert directory and set `ignoreMissing: true` for the build phase. Then
>    re-run the trust-store update after the container starts by adding a
>    `postCreateCommand` to your `devcontainer.json`:
>
>    ```json
>    "postCreateCommand": "update-ca-certificates"
>    ```
>
>    This ensures the mounted certificates are registered in the running
>    container's trust store.

## What's Installed

- `ca-certificates` — system CA certificate bundle
- `curl` — used to download certificates
- `openssl` — SSL/TLS toolkit

For every URL or local path provided the feature will:

1. **URL** — download the certificate to the OS-specific cert directory.
   **Local path** — copy the file to the OS-specific cert directory.
   In both cases a `.crt` extension is used (`.pem` → `.crt` renaming is
   applied automatically).
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
