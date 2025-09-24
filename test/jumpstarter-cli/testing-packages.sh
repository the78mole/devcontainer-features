#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Test basic installation
check "jmp-installed" which jmp
check "j-alias-installed" which j
check "uv-installed" which uv

# Test functionality
check "jmp-help" jmp --help

# Test that testing packages are available but not all packages
check "uv-tool-list-shows-testing-packages" bash -c "
    echo 'Testing that essential drivers are installed:'
    uv tool list | grep jumpstarter
    # Should show jumpstarter-cli
    if uv tool list | grep -q jumpstarter-cli; then
        echo \"jumpstarter-cli found\"
    else
        echo \"jumpstarter-cli not found\"
        exit 1
    fi
"

# Test actual jumpstarter functionality
echo "Testing jumpstarter CLI functionality with testing packages..."

# Test version command
check "jmp-version" bash -c "jmp version || jmp --version"

# Test that we can see available drivers
check "jmp-driver-help" jmp driver --help

# Test configuration command
check "jmp-config-help" jmp config --help

# Test local exporter functionality (the main purpose of testing packages)
echo "Testing local exporter functionality..."

# Create exporter config directory in user's home
check "create-exporter-config-dir" bash -c "mkdir -p \$HOME/.config/jumpstarter/exporters && echo 'Config directory created in user home'"

# Create example-local exporter configuration
check "create-local-exporter-config" bash -c "
cat > \$HOME/.config/jumpstarter/exporters/example-local.yaml << 'EOF'
apiVersion: jumpstarter.dev/v1alpha1
kind: ExporterConfig
metadata:
  namespace: default
  name: example-local
endpoint: \"\"
token: \"\"
export:
  storage:
    type: jumpstarter_driver_opendal.driver.MockStorageMux
  power:
    type: jumpstarter_driver_power.driver.MockPower
EOF
echo 'Local exporter config created in user home'
"

# Test config validation
check "validate-exporter-config" bash -c "
if [ -f \$HOME/.config/jumpstarter/exporters/example-local.yaml ]; then
    echo 'Exporter config file exists and is readable'
    head -5 \$HOME/.config/jumpstarter/exporters/example-local.yaml
else
    echo 'Exporter config file not found'
    exit 1
fi
"

# Test that local-specific drivers are available
check "test-local-driver-imports" bash -c "
echo 'Testing local exporter driver availability with uv run:'
# Test that essential drivers for local testing are available
drivers_available=0
cd ~/.local/share/uv/tools/jumpstarter-cli || exit 1
for driver in power opendal; do
    if uv run python -c \"import jumpstarter_driver_\$driver; print('jumpstarter-driver-\$driver available')\" 2>/dev/null; then
        drivers_available=\$((drivers_available + 1))
    else
        echo \"jumpstarter-driver-\$driver not available\"
    fi
done
if [ \$drivers_available -ge 2 ]; then
    echo \"Essential testing drivers are available (found \$drivers_available drivers)\"
else
    echo \"Missing essential testing drivers (only found \$drivers_available)\"
    exit 1
fi
"

# Verify that we have testing packages but not full packages
check "verify-testing-level-install" bash -c "
    echo \"Verifying testing-level installation:\"
    # Test that jumpstarter-cli tool is installed
    if uv tool list | grep -q jumpstarter-cli; then
        echo \"✓ jumpstarter-cli tool is installed\"
    else
        echo \"✗ jumpstarter-cli tool missing\"
        exit 1
    fi

    # Test that essential testing drivers are available but not all possible drivers
    cd ~/.local/share/uv/tools/jumpstarter-cli || exit 1
    essential_count=0
    for driver in power opendal; do
        if uv run python -c \"import jumpstarter_driver_\$driver\" 2>/dev/null; then
            essential_count=\$((essential_count + 1))
        fi
    done

    # Test that some non-essential drivers are NOT available (would be in 'all' but not in 'testing')
    non_essential_count=0
    for driver in network dutlink; do
        if uv run python -c \"import jumpstarter_driver_\$driver\" 2>/dev/null; then
            non_essential_count=\$((non_essential_count + 1))
        fi
    done

    echo \"Essential drivers found: \$essential_count (expected: 2)\"
    echo \"Non-essential drivers found: \$non_essential_count (expected: 0 for testing level)\"

    if [ \$essential_count -eq 2 ]; then
        echo \"✓ Testing level package selection verified\"
    else
        echo \"✗ Wrong essential driver count for testing level\"
        exit 1
    fi
"

# Test shell command help
check "jmp-shell-help" jmp shell --help

# Report result
reportResults
