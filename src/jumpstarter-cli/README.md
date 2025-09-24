# Jumpstarter CLI Feature

This DevContainer feature installs [Jumpstarter CLI](https://github.com/jumpstarter-dev/jumpstarter),
providing the `jmp` and `j` commands as global tools via uv.

## Options

| Option      | Type   | Default       | Description                              |
| ----------- | ------ | ------------- | ---------------------------------------- |
| version     | string | "latest"      | Version of jumpstarter-cli to install    |
| packageRepo | string | "jumpstarter" | Package repository to use                |
| packages    | string | "none"        | Package set: "none", "testing", or "all" |

## Usage

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/jumpstarter-cli": {
      "version": "latest",
      "packageRepo": "jumpstarter",
      "packages": "testing"
    }
  }
}
```

## What's Installed

### Basic Installation (`packages: "none"`)

- `jmp` - Jumpstarter CLI main command
- `j` - Jumpstarter CLI short alias command
- Global PATH configuration for all users
- Core jumpstarter-cli functionality and admin tools

### Testing Installation (`packages: "testing"`)

In addition to the basic installation, this includes essential drivers for
local development and testing:

- **jumpstarter-driver-power**: Power management and mock power implementations
- **jumpstarter-driver-opendal**: Storage driver with OpenDAL integration
- **Local exporter support**: Enables local development workflows without
  full hardware setup
- **Essential testing utilities**: Mock implementations for development

This package level is optimized for developers who want to test jumpstarter
functionality locally or develop exporters without needing all driver packages.

### Complete Installation (`packages: "all"`)

When `packages` is set to `"all"`, the feature installs `jumpstarter-all`
alongside `jumpstarter-cli` using the `--with` flag. This provides access to
all jumpstarter driver packages and utilities, including:

- **All driver packages**: dutlink, power, storage, network, console, gpio,
  opendal, and many more
- **Full exporter functionality**: Complete exporter capabilities for local
  and distributed setups
- **Comprehensive testing utilities**: All mock implementations and testing tools
- **Hardware integration support**: Drivers for real hardware components

## Package Level Options

### `packages: "none"` (default)

Installs only the core jumpstarter CLI tools. This is suitable for basic usage,
administrative tasks, and scenarios where you only need the CLI commands
without driver integrations.

### `packages: "testing"`

Includes essential drivers for local development and testing. This level is
perfect for:

- Local development workflows
- Testing jumpstarter functionality without hardware
- Developing custom exporters
- Educational and learning purposes

### `packages: "all"`

Provides complete jumpstarter functionality with all available drivers. This is
recommended for:

- Production deployments
- Hardware integration projects
- Full jumpstarter capability requirements
- Complex testing scenarios with multiple drivers

## Dependencies

This feature requires the `uv` Python package installer. If `uv` is not found, it
will be automatically installed. For better control, you can explicitly include
the `uv` feature in your devcontainer configuration:

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/uv": {},
    "ghcr.io/the78mole/devcontainer-features/jumpstarter-cli": {}
  }
}
```

## Package Repository Options

### jumpstarter (default)

- Repository: `pkg.jumpstarter.dev`
- Available versions: `latest` (0.7.0), `main`
- Use case: Latest features and main branch development

### pypi

- Repository: PyPI (`pypi.org`)
- Available versions: Specific versions like `0.6.0`
- Use case: Stable releases and version-specific installations
- Note: Latest versions may not be available immediately on PyPI

### Custom Repository

- Specify a custom package repository URL starting with `https://`
- Example: `"https://custom-repo.example.com/simple/"`
- Use case: Private or alternative package repositories

## Notes

- This feature automatically installs
  [uv](https://github.com/astral-sh/uv) if not available and
- jumpstarter-cli is installed as a global uv tool for easy access
- After installation, you can use `jmp` and `j` commands in your terminal
- The tool provides access to Jumpstarter CLI functionality for hardware
  testing and automation

## Example Commands

After installation, you can use jumpstarter commands like:

```bash
# Check version
jmp --version

# Use short alias
j --version

# Get help
jmp --help
j --help

# With packages: "testing", you can also:
# Create local exporter configuration
mkdir -p ~/.config/jumpstarter/exporters
cat > ~/.config/jumpstarter/exporters/example-local.yaml << EOF
apiVersion: jumpstarter.dev/v1alpha1
kind: ExporterConfig
metadata:
  namespace: default
  name: example-local
endpoint: ""
token: ""
export:
  storage:
    type: jumpstarter_driver_opendal.driver.MockStorageMux
  power:
    type: jumpstarter_driver_power.driver.MockPower
EOF

# Test local shell connection
jmp shell --exporter example-local
```

## Installation Examples

### Latest from Jumpstarter repository (recommended)

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/jumpstarter-cli": {
      "version": "latest",
      "packageRepo": "jumpstarter"
    }
  }
}
```

### Specific version from PyPI

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/jumpstarter-cli": {
      "version": "0.6.0",
      "packageRepo": "pypi"
    }
  }
}
```

### Custom repository

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/jumpstarter-cli": {
      "version": "latest",
      "packageRepo": "https://pkg.jumpstarter.dev/simple/"
    }
  }
}
```

### Complete installation with testing packages

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/jumpstarter-cli": {
      "version": "latest",
      "packageRepo": "jumpstarter",
      "packages": "testing"
    }
  }
}
```

### Complete installation with all packages

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/jumpstarter-cli": {
      "version": "latest",
      "packageRepo": "jumpstarter",
      "packages": "all"
    }
  }
}
```
