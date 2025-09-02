# Changelog

## [1.0.0] - 2024-09-02

### Added

- Initial release of uv (Python Package Manager) devcontainer feature
- Support for uv versions (latest, 0.4.18, 0.4.17, 0.4.16, 0.4.15)
- Multiple installation methods with intelligent fallback mechanisms
- Comprehensive test suite across multiple Python versions
- Matrix testing in CI workflows
- Global PATH configuration for all users

### Features

- uv installation via official installer (preferred method)
- Fallback to pip installation when official installer unavailable
- Mock binary support for isolated testing environments
- Integration with Python devcontainer features via `installsAfter`
- Supports both network-connected and restricted environments
- Executable permissions and PATH configuration management
- Version selection support through feature options

### Installation Methods

1. **Primary**: Official uv installer from astral.sh
2. **Fallback 1**: Python pip installation (`pip install uv`)
3. **Fallback 2**: System package manager
4. **Fallback 3**: Mock binary for testing in isolated environments

### Testing

- Comprehensive test coverage including:
  - Installation verification
  - Version checking
  - PATH configuration
  - Executable permissions
  - Basic command functionality (uv, uv pip, uv init)
- Matrix testing across Python 3.11 and 3.12 base images
- Support for multiple uv versions in CI

### Notes

- Based on the uv feature from [the78mole/jumpstarter-server](https://github.com/the78mole/jumpstarter-server/tree/main/.devcontainer/features/uv)
- Designed for development containers with fast Python package management
- Compatible with existing pip and requirements.txt workflows
- Excellent performance improvements over traditional pip workflows
- Supports modern Python packaging standards (pyproject.toml, dependency groups)
