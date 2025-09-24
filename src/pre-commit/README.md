# pre-commit Feature

This DevContainer feature installs [pre-commit](https://pre-commit.com/), a framework for managing and maintaining multi-language pre-commit hooks.

## Options

| Option  | Type   | Default  | Description                   |
| ------- | ------ | -------- | ----------------------------- |
| version | string | "latest" | Version of pre-commit to install |

## Usage

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/pre-commit": {
      "version": "latest"
    }
  }
}
```

## What's Installed

- `pre-commit` - Framework for managing pre-commit hooks
- Global PATH configuration for all users

## Dependencies

This feature depends on the `uv` feature and will be installed after it.

## Notes

- This feature requires the `uv` feature to be installed first
- pre-commit is installed as a global uv tool for easy access
- After installation, use `pre-commit install` in your repository to set up git hooks
- Configuration is done via `.pre-commit-config.yaml` file in your repository root

## Example Commands

After installation, you can use pre-commit commands like:

```bash
# Install pre-commit hooks in your repository
pre-commit install

# Run hooks against all files
pre-commit run --all-files

# Update hooks to latest versions
pre-commit autoupdate

# Run specific hook
pre-commit run <hook-id>
```

## Example Configuration

Create a `.pre-commit-config.yaml` file in your repository:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
```