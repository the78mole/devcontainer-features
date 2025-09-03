# PostgreSQL (postgresql)

Installs PostgreSQL database server and client tools with automatic initialization.

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
- **Automatic startup** when devcontainer is created
- Initialization script created at `/usr/local/share/pq-init.sh`
- Binary symlinks created in `/usr/local/bin` for easy access to PostgreSQL tools
- Devcontainer user added to `postgres` group with necessary sudo permissions

### Binary Access

All PostgreSQL binaries are automatically symlinked to `/usr/local/bin`,
making them available in your PATH:

```bash
psql --version          # PostgreSQL client
postgres --version      # PostgreSQL server
pg_dump --version       # Database backup tool
createdb mydb           # Create database utility
# ... and all other PostgreSQL utilities
```

### Starting PostgreSQL

PostgreSQL starts automatically when the devcontainer is created. If you need to
restart it manually, you can use:

```bash
/usr/local/share/pq-init.sh
```

### User Permissions

The devcontainer user is automatically added to the `postgres` group and has the
necessary sudo permissions to manage PostgreSQL without requiring a password.
This allows you to:

- Start and stop PostgreSQL services
- Initialize databases
- Run PostgreSQL administration commands

### Connecting to PostgreSQL

Connect to PostgreSQL using the `psql` client:

```bash
psql -U postgres
```

## Environment Variables

The following environment variable is set:

- `PGDATA=/var/lib/postgresql/data` - PostgreSQL data directory

## Notes

- PostgreSQL is configured for development use with trust authentication
- For production use, you should configure proper authentication and security settings
- The feature creates an initialization script that handles database setup and startup
- PostgreSQL will be configured to accept connections from any IP address
  (suitable for container development)
- All PostgreSQL binaries are automatically available in PATH via symlinks
- Only distributions supported by the official PostgreSQL APT repository are
  supported

## OS Support

This feature supports:

- **Ubuntu**: jammy (22.04), noble (24.04), plucky (25.04)
- **Debian**: bullseye (11), bookworm (12), sid (unstable), trixie (testing)
- **Architectures**: amd64, arm64, i386, ppc64el

Note: Support is limited to distributions available in the official PostgreSQL
APT repository.

---

_Note: This feature is based on the excellent work from
[itsmechlark/features](https://github.com/itsmechlark/features)._
