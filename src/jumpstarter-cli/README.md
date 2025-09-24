# Jumpstarter CLI Feature

This DevContainer feature installs [Jumpstarter CLI](https://github.com/jumpstarter-dev/jumpstarter),
providing the `jmp` and `j` commands as global tools via uv.

## Options

| Option             | Type    | Default       | Description                           |
| ------------------ | ------- | ------------- | ------------------------------------- |
| version            | string  | "latest"      | Version of jumpstarter-cli to install |
| packageRepo        | string  | "jumpstarter" | Package repository to use             |
| installAllPackages | boolean | false         | Install all jumpstarter packages      |

## Usage

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/jumpstarter-cli": {
      "version": "latest",
      "packageRepo": "jumpstarter",
      "installAllPackages": true
    }
  }
}
```

## What's Installed

### Basic Installation

- `jmp` - Jumpstarter CLI main command
- `j` - Jumpstarter CLI short alias command
- Global PATH configuration for all users

### With `installAllPackages: true`

When `installAllPackages` is set to `true`, the feature installs `jumpstarter-all`
alongside `jumpstarter-cli` using the `--with` flag. This provides access to all
jumpstarter driver packages and utilities, including:

- **Driver packages**: dutlink, power, storage, network, console, gpio, opendal,
  and many more
- **Exporter functionality**: Full exporter capabilities for local and
  distributed setups
- **Testing utilities**: Mock implementations for development and testing
  without hardware

This enables complete jumpstarter functionality including local exporter setup
as described in the [Jumpstarter Local Mode documentation](https://jumpstarter.dev/release-0.6/getting-started/usage/setup-local-mode.html).

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

# With installAllPackages: true, you can also:
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

### Complete installation with all packages

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/jumpstarter-cli": {
      "version": "latest",
      "packageRepo": "jumpstarter",
      "installAllPackages": true
    }
  }
}
```
