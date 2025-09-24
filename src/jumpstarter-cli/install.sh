#!/bin/bash
set -e

# Parse input arguments
VERSION=${VERSION:-"latest"}
PACKAGE_REPO=${PACKAGEREPO:-"jumpstarter"}

echo "Installing Jumpstarter CLI..."

# Check if Python is available (required for jumpstarter-cli)
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo "📦 Python not found - installing Python first..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y python3 python3-pip python3-venv
    elif command -v apk &> /dev/null; then
        apk add python3 py3-pip
    elif command -v yum &> /dev/null; then
        yum install -y python3 python3-pip
    elif command -v pacman &> /dev/null; then
        pacman -S python python-pip
    else
        echo "❌ Cannot install Python - unsupported package manager"
        echo "   Please use a base image with Python pre-installed"
        exit 1
    fi
    echo "✅ Python installed successfully"
fi

# Check if uv is available
if ! command -v uv &> /dev/null; then
    echo "📦 uv not found - installing uv first..."
    # Install curl if not available
    if ! command -v curl &> /dev/null; then
        echo "📦 Installing curl..."
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y curl
        elif command -v apk &> /dev/null; then
            apk add curl
        elif command -v yum &> /dev/null; then
            yum install -y curl
        elif command -v pacman &> /dev/null; then
            pacman -S --noconfirm curl
        else
            echo "❌ Could not install curl - package manager not found"
            exit 1
        fi
    fi

    # Install uv using the official installer
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Source the environment to make uv available - try multiple locations
    export PATH="$HOME/.local/bin:$PATH"
    if ! command -v uv &> /dev/null; then
        # Try cargo bin location
        export PATH="$HOME/.cargo/bin:$PATH"
        if ! command -v uv &> /dev/null; then
            # Try system-wide location
            export PATH="/usr/local/bin:$PATH"
            if ! command -v uv &> /dev/null; then
                # Try root's local bin
                export PATH="/root/.local/bin:$PATH"
                if ! command -v uv &> /dev/null; then
                    echo "❌ Failed to install uv - please install uv manually first"
                    echo "Tried paths: \$HOME/.local/bin, \$HOME/.cargo/bin, /usr/local/bin, /root/.local/bin"
                    exit 1
                fi
            fi
        fi
    fi
    echo "✅ uv installed successfully"

    # Ensure uv binary has execute permissions
    # Add execute permission and check for existence
    chmod +x "$HOME"/.local/bin/uv 2>/dev/null || true
    chmod +x "$HOME"/.cargo/bin/uv 2>/dev/null || true

    # Ensure uv is in PATH immediately after installation
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:/root/.local/bin:$PATH"

    # Wait a moment for installation to complete
    sleep 1
fi

# Final verification that uv is available
if ! command -v uv &> /dev/null; then
    echo "❌ uv command not found in PATH after installation"
    echo "Current PATH: $PATH"
    echo "Checking common locations:"
    echo "DEBUG: Checking for uv binary location..."
    ls -la "$HOME"/.local/bin/uv 2>/dev/null && echo "Found in $HOME/.local/bin/" || echo "Not in $HOME/.local/bin/"
    ls -la "$HOME"/.cargo/bin/uv 2>/dev/null && echo "Found in $HOME/.cargo/bin/" || echo "Not in $HOME/.cargo/bin/"
    ls -la /usr/local/bin/uv 2>/dev/null && echo "Found in /usr/local/bin/" || echo "Not in /usr/local/bin/"
    ls -la /root/.local/bin/uv 2>/dev/null && echo "Found in /root/.local/bin/" || echo "Not in /root/.local/bin/"
    exit 1
fi

# Determine installation source based on package repository
case "$PACKAGE_REPO" in
    "jumpstarter")
        echo "📦 Using Jumpstarter package repository (pkg.jumpstarter.dev)"
        if [ "$VERSION" = "latest" ]; then
            # Use pkg.jumpstarter.dev for latest (currently 0.7.0)
            PACKAGE_SOURCE="--extra-index-url https://pkg.jumpstarter.dev/simple jumpstarter-cli"
            echo "   Installing latest version from pkg.jumpstarter.dev"
        elif [ "$VERSION" = "main" ]; then
            # Use pkg.jumpstarter.dev/main/ for main branch
            PACKAGE_SOURCE="--extra-index-url https://pkg.jumpstarter.dev/main/simple jumpstarter-cli"
            echo "   Installing main branch from pkg.jumpstarter.dev/main/"
        else
            echo "⚠️  Specific versions not supported on pkg.jumpstarter.dev"
            echo "   Available versions: 'latest' (0.7.0), 'main'"
            echo "   Falling back to latest version"
            PACKAGE_SOURCE="--extra-index-url https://pkg.jumpstarter.dev/simple jumpstarter-cli"
        fi
        ;;
    "pypi")
        echo "📦 Using PyPI package repository"
        if [ "$VERSION" = "latest" ]; then
            PACKAGE_SOURCE="jumpstarter-cli"
            echo "   Installing latest version from PyPI"
        else
            PACKAGE_SOURCE="jumpstarter-cli==$VERSION"
            echo "   Installing version $VERSION from PyPI"
        fi
        ;;
    *)
        # Check if it's a URL (contains http:// or https://)
        if [[ "$PACKAGE_REPO" =~ ^https?:// ]]; then
            echo "🌐 Using custom package repository: $PACKAGE_REPO"
            if [ "$VERSION" = "latest" ]; then
                PACKAGE_SOURCE="--extra-index-url $PACKAGE_REPO jumpstarter-cli"
                echo "   Installing latest version from custom repository"
            else
                PACKAGE_SOURCE="--extra-index-url $PACKAGE_REPO jumpstarter-cli==$VERSION"
                echo "   Installing version $VERSION from custom repository"
            fi
        else
            echo "❌ Unsupported package repository: $PACKAGE_REPO"
            echo "   Supported:"
            echo "     - 'jumpstarter' (pkg.jumpstarter.dev)"
            echo "     - 'pypi' (pypi.org)"
            echo "     - Custom URL (https://your-repo.example.com/simple/)"
            exit 1
        fi
        ;;
esac

# Find the correct uv path
UV_PATH=""
if [ -f "/root/.local/bin/uv" ]; then
    UV_PATH="/root/.local/bin/uv"
elif [ -f "$HOME/.local/bin/uv" ]; then
    UV_PATH="$HOME/.local/bin/uv"
elif [ -f "$HOME/.cargo/bin/uv" ]; then
    UV_PATH="$HOME/.cargo/bin/uv"
elif [ -f "/usr/local/bin/uv" ]; then
    UV_PATH="/usr/local/bin/uv"
else
    echo "❌ Cannot find uv executable"
    exit 1
fi

# Ensure the uv binary is executable
chmod +x "$UV_PATH"

echo "Using uv at: $UV_PATH"

# Install jumpstarter-cli as a uv tool for global access
echo "Installing Jumpstarter CLI as global tool..."
echo "   Repository: $PACKAGE_REPO"
echo "   Version: $VERSION"
echo "   Command: $UV_PATH tool install $PACKAGE_SOURCE"

# Ensure uv binary is executable before using it
if [ -f "$UV_PATH" ]; then
    chmod +x "$UV_PATH" 2>/dev/null || true
    # Double-check it's executable
    if [ ! -x "$UV_PATH" ]; then
        echo "WARNING: $UV_PATH is not executable, trying alternative execution method"
        # Use python to execute the binary directly
        python3 -c "
import subprocess
import os
result = subprocess.run(['$UV_PATH', 'tool', 'install', '$PACKAGE_SOURCE'], capture_output=True, text=True)
print(result.stdout)
if result.stderr:
    print('STDERR:', result.stderr)
exit(result.returncode)
"
    else
        # Normal execution
        # Install jumpstarter-cli for the vscode user (or current user)
        if id "vscode" &>/dev/null; then
            sudo -u vscode bash -c "export PATH=\"$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:/root/.local/bin:\$PATH\" && $UV_PATH tool install $PACKAGE_SOURCE"
            echo "✅ Jumpstarter CLI installed for vscode user from $PACKAGE_REPO repository"
        elif [ "$USER" != "root" ]; then
            bash -c "export PATH=\"$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:/root/.local/bin:\$PATH\" && $UV_PATH tool install $PACKAGE_SOURCE"
            echo "✅ Jumpstarter CLI installed for $USER from $PACKAGE_REPO repository"
        else
            # For root user, install globally accessible
            bash -c "export PATH=\"$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:/root/.local/bin:\$PATH\" && $UV_PATH tool install $PACKAGE_SOURCE"
            echo "✅ Jumpstarter CLI installed for root user from $PACKAGE_REPO repository"
        fi
    fi
else
    echo "ERROR: uv binary not found at $UV_PATH"
    exit 1
fi

# Handle post-installation steps only for normal execution
if [ -x "$UV_PATH" ]; then
    # Make sure the tools are available in PATH for all users
    if [ -f "/root/.local/bin/jmp" ]; then
        ln -sf /root/.local/bin/jmp /usr/local/bin/jmp
    fi
    if [ -f "/root/.local/bin/j" ]; then
        ln -sf /root/.local/bin/j /usr/local/bin/j
    fi
    echo "✅ Jumpstarter CLI installed globally from $PACKAGE_REPO repository"
fi

# Verify installation
echo "Verifying Jumpstarter CLI installation..."
if command -v jmp &> /dev/null; then
    echo "✅ jmp command available: $(jmp --version 2>/dev/null || echo 'installed')"
    echo "   Package repository: $PACKAGE_REPO"
    echo "   Requested version: $VERSION"
else
    echo "⚠️ jmp installed but not in PATH - may need container restart"
fi

if command -v j &> /dev/null; then
    echo "✅ j command (short alias) available"
else
    echo "ℹ️ j command not found - may be available after container restart"
fi

echo ""
echo "📋 Package Repository Information:"
case "$PACKAGE_REPO" in
    "jumpstarter")
        echo "   Repository: pkg.jumpstarter.dev"
        echo "   Available versions: latest (0.7.0), main"
        echo "   Use case: Latest features and main branch development"
        ;;
    "pypi")
        echo "   Repository: PyPI (pypi.org)"
        echo "   Available versions: Specific versions like 0.6.0"
        echo "   Use case: Stable releases and version-specific installations"
        echo "   Note: 0.7.0 may not be available yet on PyPI"
        ;;
    *)
        if [[ "$PACKAGE_REPO" =~ ^https?:// ]]; then
            echo "   Repository: Custom ($PACKAGE_REPO)"
            echo "   Use case: Private or alternative package repositories"
            echo "   Note: Using --extra-index-url to supplement PyPI"
        fi
        ;;
esac

echo "✅ Jumpstarter CLI feature installation complete!"
