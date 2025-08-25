# Commit Message Conventions

This project uses semantic versioning with automatic version generation
based on commit messages.

## Version Bumping

### Major Version (Breaking Changes)

Use `!:` or `+semver: breaking` or `+semver: major` in your commit message:

```bash
git commit -m "feat!: remove deprecated API endpoint"
git commit -m "refactor!: change database schema"
git commit -m "feat: add new feature +semver: major"
```

### Minor Version (New Features)

Use conventional commit prefixes or `+semver: feature` or `+semver: minor`:

```bash
git commit -m "feat: add new PostgreSQL configuration option"
git commit -m "fix: resolve connection timeout issue"
git commit -m "perf: improve startup performance"
git commit -m "refactor: optimize database queries"
git commit -m "docs: update README +semver: minor"
```

### Patch Version (Bug Fixes)

Any other commit that doesn't match the patterns above:

```bash
git commit -m "docs: fix typo in README"
git commit -m "ci: update workflow dependencies"
git commit -m "test: add missing test cases"
```

## Automatic Workflow

1. **On Push to Main**: The `version.yml` workflow runs
2. **Version Generation**: Creates a new semantic version based on commit
   messages
3. **Tag Creation**: Automatically creates and pushes a new git tag
4. **Release Creation**: Creates a GitHub release with changelog
5. **Feature Publishing**: The `release.yml` workflow triggers on new tags and
   publishes features

## Examples

```bash
# Patch: 1.0.0 -> 1.0.1
git commit -m "docs: update installation instructions"

# Minor: 1.0.1 -> 1.1.0
git commit -m "feat: add connection pooling support"

# Major: 1.1.0 -> 2.0.0
git commit -m "feat!: change default PostgreSQL version to 17"
```

## Pattern Details

- **Major Pattern**: `/(\\+semver:\\s?(breaking|major)|!:)/`
- **Minor Pattern**: `/(\\+semver:\\s?(feature|minor)|^feat|^fix|^perf|^refactor)/`
- **Flags**: Case-insensitive matching with global and multiline support
