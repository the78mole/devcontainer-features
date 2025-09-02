# devcontainer-features

This repository contains high-quality DevContainer features for modern
development workflows. These features are designed to work together seamlessly
and provide a great developer experience out of the box.

## Features

This repository provides the following devcontainer features:

- [`postgresql`](./src/postgresql/README.md) - PostgreSQL database server and
  client tools with automatic setup
- [`uv`](./src/uv/README.md) - An extremely fast Python package and project
  manager written in Rust

## Usage

To use these features in your devcontainer, add them to your `devcontainer.json`:

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/the78mole/devcontainer-features/postgresql:1": {
      "version": "16"
    },
    "ghcr.io/the78mole/devcontainer-features/uv:1": {
      "version": "latest"
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

### uv Feature

The uv feature installs uv, an extremely fast Python package and project
manager written in Rust:

- **Lightning fast:** Significantly faster than pip for dependency resolution
- **Modern Python packaging:** Full support for pyproject.toml and dependency
  groups
- **Drop-in replacement:** Compatible with existing pip and requirements.txt
  workflows
- **Project management:** Create and manage Python projects with ease

#### uv Quick Start

After the feature is installed, use uv commands:

```bash
# Create a new Python project
uv init my-project
cd my-project

# Add dependencies
uv add requests pandas

# Run Python with dependencies
uv run python script.py

# Install packages (pip-compatible)
uv pip install flask
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

- `devcontainer.json` - Basic test environment configuration
- `test.sh` - Basic test script to verify the feature works correctly
- `scenarios.json` - Defines additional test scenarios for feature combinations
- `<scenario-name>.sh` - Test scripts for specific scenarios (e.g., `with-uv.sh`)
- `scenarios/<scenario-name>/devcontainer.json` - Container configuration for scenarios

#### Example: PostgreSQL + uv Integration Test

The `with-uv` scenario tests PostgreSQL and uv working together:

```json
// test/postgresql/scenarios.json
{
  "with-uv": {
    "image": "mcr.microsoft.com/devcontainers/python:3.12",
    "features": {
      "postgresql": { "version": "16" },
      "uv": { "version": "latest" }
    }
  }
}
```

The test script `test/postgresql/with-uv.sh` validates both features work
together by creating a uv project and testing Python database connectivity:

```bash
# Example workflow tested in the scenario
uv init database-project
cd database-project
uv add psycopg2-binary
uv run python -c "import psycopg2; print('Database connectivity ready!')"
```

Run tests with:

```bash
# Test all features
devcontainer features test .

# Test specific feature
devcontainer features test -f postgresql

# Test specific scenario
devcontainer features test -f postgresql --filter with-uv
```

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
│       ├── devcontainer.json          # Basic test configuration
│       ├── test.sh                    # Basic feature tests
│       ├── scenarios.json             # Scenario definitions
│       ├── <scenario-name>.sh         # Scenario test scripts
│       └── scenarios/
│           └── <scenario-name>/
│               └── devcontainer.json  # Scenario container config
└── devcontainer-features.json
```

## License

See [LICENSE](./LICENSE) for more information.
