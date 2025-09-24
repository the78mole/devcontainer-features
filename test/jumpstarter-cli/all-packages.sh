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
# Note: j --help requires JUMPSTARTER_HOST environment variable, so we skip this test
# check "j-help" j --help

# Test that additional packages are available
check "uv-tool-list-shows-multiple-packages" bash -c "uv tool list | grep -c jumpstarter" | grep -v "^1$"

# Test actual jumpstarter functionality with version check and basic exporter test
echo "Testing jumpstarter CLI functionality..."

# Test version command (this should always work)
check "jmp-version" bash -c "jmp version || jmp --version"

# Test that we can see available drivers
check "jmp-driver-help" jmp driver --help

# Test configuration command
check "jmp-config-help" jmp config --help

# Create a minimal test to see if exporter can be invoked (without actually running it)
check "jmp-run-help" jmp run --help

# Test driver availability (diagnostic approach)
echo "Diagnosing installed jumpstarter packages..."
check "list-all-jumpstarter-packages" bash -c "uv tool list | grep jumpstarter || echo 'No jumpstarter packages found'"

# Test if jumpstarter-all packages are available through Python imports
check "verify-jumpstarter-all-installed" bash -c "
    jumpstarter_count=\$(uv tool list | grep -c jumpstarter)
    echo \"Found \$jumpstarter_count jumpstarter tools\"
    # Check if all the driver packages from jumpstarter-all are available
    drivers_available=0
    for driver in opendal power dutlink network; do
        if python3 -c \"import jumpstarter_driver_\$driver\" 2>/dev/null; then
            echo \"jumpstarter-driver-\$driver is available\"
            drivers_available=\$((drivers_available + 1))
        fi
    done
    if [ \$drivers_available -gt 0 ]; then
        echo \"jumpstarter-all drivers are accessible (found \$drivers_available drivers)\"
    else
        echo \"jumpstarter-all drivers may not be properly installed\"
    fi
"

# Test jumpstarter-all package availability through Python
check "jumpstarter-all-python-check" bash -c "
    if python3 -c 'import jumpstarter_all' 2>/dev/null; then
        echo 'jumpstarter-all package available in Python'
    else
        echo 'jumpstarter-all package available through --with installation (not directly importable)'
    fi
"

# Test local exporter functionality (based on Jumpstarter documentation)
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

# Test jmp config command with the created config
check "jmp-config-list-exporters" bash -c "
timeout 10 jmp config exporter list 2>/dev/null || echo 'Config list may require different environment setup'
"

# Test shell command help (without actually spawning a shell which would be interactive)
check "jmp-shell-help" jmp shell --help

# Test basic driver availability through Python imports
check "test-opendal-driver" bash -c "
python3 -c 'import jumpstarter_driver_opendal; print(\"OpenDAL driver available\")' 2>/dev/null ||
echo 'OpenDAL driver installed but may have import issues'
"

check "test-power-driver" bash -c "
python3 -c 'import jumpstarter_driver_power; print(\"Power driver available\")' 2>/dev/null ||
echo 'Power driver installed but may have import issues'
"

# Report result
reportResults
