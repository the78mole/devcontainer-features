# uv Feature

This DevContainer feature installs [uv](https://docs.astral.sh/uv/), an extremely fast Python package and project manager written in Rust.

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| version | string | "latest" | Version of uv to install |

## Usage

```json
{
    "features": {
        "ghcr.io/the78mole/devcontainer-features/uv": {
            "version": "latest"
        }
    }
}
```

## What's Installed

- `uv` - Python package and project manager
- Global PATH configuration for all users

## Notes

- This feature should be installed after the Python feature
- uv provides faster dependency resolution and installation compared to pip
- Compatible with existing pip and requirements.txt workflows
- Supports modern Python packaging with pyproject.toml and dependency groups
- Excellent for managing virtual environments and development dependencies

## Example Commands

After installation, you can use uv commands like:

```bash
# Install packages
uv pip install requests

# Create a new project
uv init my-project

# Run a script with dependencies
uv run --with requests python script.py

# Sync dependencies from pyproject.toml
uv sync
```