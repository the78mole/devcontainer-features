# Changelog

## [1.1.0] - TBD

### Added

- **Automatic PostgreSQL startup** when devcontainer is created via `postCreateCommand`
- **Enhanced user permissions** - devcontainer user added to postgres group
- **Passwordless sudo access** for PostgreSQL operations (initdb, pg_ctl, service management)
- **Seamless administration** without requiring manual sudo for basic operations

### Changed

- PostgreSQL now starts automatically on devcontainer creation
- Updated documentation to reflect automatic startup and improved user permissions
- Enhanced user experience by eliminating manual PostgreSQL startup requirement

### Fixed

- Resolved issue where PostgreSQL required manual startup
- Fixed permission issues preventing non-root users from administering PostgreSQL

## [1.0.0] - 2025-08-25

### Added

- Initial release of PostgreSQL devcontainer feature
- Support for PostgreSQL versions 11-17 and latest
- Automatic database initialization with trust authentication
- VS Code PostgreSQL extension integration
- Initialization script for easy PostgreSQL startup
- Support for multiple architectures (amd64, arm64, i386, ppc64el)
- Support for Ubuntu and Debian distributions
- Environment variable PGDATA configuration
- Comprehensive test suite

### Features

- PostgreSQL server and client installation from official PostgreSQL APT repository
- Automatic database initialization on first run
- Network configuration for development containers
- Trust authentication for development convenience
- IPv6 support
- Startup script at `/usr/local/share/pq-init.sh`

### Notes

- Based on the excellent work from [itsmechlark/features](https://github.com/itsmechlark/features)
- Configured for development use with trust authentication
- PostgreSQL configured to accept connections from any IP address
