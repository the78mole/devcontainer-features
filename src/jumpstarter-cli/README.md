# Jumpstarter CLI Feature

This DevContainer feature installs [Jumpstarter CLI](https://github.com/jumpstarter-dev/jumpstarter),
providing the `jmp` and `j` commands as global tools via uv.

## Options

| Option      | Type   | Default       | Description                           |
| ----------- | ------ | ------------- | ------------------------------------- |
| version     | string | "latest"      | Version of jumpstarter-cli to install |
| packageRepo | string | "jumpstarter" | Package repository to use             |

## Usage

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

## What's Installed

- `jmp` - Jumpstarter CLI main command
- `j` - Jumpstarter CLI short alias command
- Global PATH configuration for all users

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
