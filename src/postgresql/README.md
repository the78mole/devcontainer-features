# PostgreSQL

Installs PostgreSQL database server and client tools.

## Example Usage

```json
"features": {
    "ghcr.io/the78mole/devcontainer-features/postgresql:1": {}
}
```

## Options

| Options Id | Description                   | Type   | Default Value |
| ---------- | ----------------------------- | ------ | ------------- |
| version    | PostgreSQL version to install | string | latest        |

## Supported versions

This feature supports the following PostgreSQL versions:

- `latest` (default) - Installs the latest available version
- `17` - PostgreSQL 17
- `16` - PostgreSQL 16
- `15` - PostgreSQL 15
- `14` - PostgreSQL 14
- `13` - PostgreSQL 13
- `12` - PostgreSQL 12
- `11` - PostgreSQL 11

## Usage

This feature installs PostgreSQL server and client tools with the following
configuration:

- PostgreSQL server configured to listen on all addresses
- Data directory set to `/var/lib/postgresql/data`
- PostgreSQL configured with trust authentication for development
- Initialization script created at `/usr/local/share/pq-init.sh`

### Starting PostgreSQL

After installation, you can start PostgreSQL with:

```bash
sudo /usr/local/share/pq-init.sh
```

### Connecting to PostgreSQL

Connect to PostgreSQL using the `psql` client:

```bash
psql -U postgres
```

## VS Code Extensions

This feature automatically installs the recommended PostgreSQL extension for
VS Code:

- `ms-ossdata.vscode-postgresql` - PostgreSQL extension for VS Code

## Environment Variables

The following environment variable is set:

- `PGDATA=/var/lib/postgresql/data` - PostgreSQL data directory

## Notes

- PostgreSQL is configured for development use with trust authentication
- For production use, you should configure proper authentication and security
  settings
- The feature creates an initialization script that handles database setup and
  startup
- PostgreSQL will be configured to accept connections from any IP address
  (suitable for container development)

## OS Support

This feature supports:

- Ubuntu (bionic, focal, jammy, kinetic, noble)
- Debian (bullseye, bookworm, buster, sid)
- Architectures: amd64, arm64, i386, ppc64el

---

_Note: This feature is based on the excellent work from
[itsmechlark/features](https://github.com/itsmechlark/features)._
