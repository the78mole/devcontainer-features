# devcontainer-features

This is a repository containing devcontainer features, mainly to complement the hwdev-template.

## Features

This repository provides the following devcontainer features:

- [`postgresql`](./src/postgresql/README.md) - PostgreSQL database server and
  client tools with automatic setup

## Usage

To use these features in your devcontainer, add them to your `devcontainer.json`:

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/the78mole/devcontainer-features/postgresql:1": {
      "version": "16"
    }
  }
}
```

### PostgreSQL Feature

The PostgreSQL feature installs PostgreSQL server and client tools with
development-friendly configuration:

- **Supported versions:** 11, 12, 13, 14, 15, 16, 17, latest
- **Automatic database initialization** with trust authentication
- **VS Code integration** with PostgreSQL extension
- **Easy startup** via `/usr/local/share/pq-init.sh`
- **Network access** configured for container development

#### Quick Start

After the feature is installed, start PostgreSQL and connect:

```bash
# Start PostgreSQL
sudo /usr/local/share/pq-init.sh

# Connect to database
psql -U postgres
```

## Development

### Prerequisites

This repository uses [pre-commit](https://pre-commit.com/) to ensure code
quality. Install it with:

```bash
pip install pre-commit
pre-commit install
```

### Adding a new feature

1. Create a new directory under `src/` with your feature name
2. Add a `devcontainer-feature.json` file with feature metadata
3. Add an `install.sh` script that performs the installation
4. Add a `README.md` with documentation
5. Create tests under `test/` directory

### Testing features

Tests are located in the `test/` directory. Each feature should have its own
test directory with:

- `devcontainer.json` - Test environment configuration
- `test.sh` - Test script to verify the feature works correctly

### Code Quality

This repository uses pre-commit hooks to maintain code quality:

- **Shell scripts:** Validated with ShellCheck
- **JSON files:** Syntax validation and formatting
- **Markdown:** Linting and formatting with markdownlint
- **YAML files:** Syntax validation and formatting
- **Custom checks:** Feature configuration validation, executable
  permissions

Run all checks manually:

```bash
pre-commit run --all-files
```

### Structure

```text
├── src/
│   └── <feature-name>/
│       ├── devcontainer-feature.json
│       ├── install.sh
│       └── README.md
├── test/
│   └── <feature-name>/
│       ├── devcontainer.json
│       └── test.sh
└── devcontainer-features.json
```

## License

See [LICENSE](./LICENSE) for more information.
