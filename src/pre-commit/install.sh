#!/bin/bash
set -e

# Parse input arguments
VERSION=${VERSION:-"latest"}

echo "Installing pre-commit framework..."

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
fi

# Install pre-commit using uv
echo "Installing pre-commit using uv..."

# Determine installation command based on version
if [ "$VERSION" = "latest" ]; then
    PACKAGE_SOURCE="pre-commit"
    echo "   Installing latest version of pre-commit"
else
    PACKAGE_SOURCE="pre-commit==$VERSION"
    echo "   Installing pre-commit version $VERSION"
fi

# Install pre-commit as a uv tool for global access
echo "Installing pre-commit as global tool..."
echo "   Command: uv tool install $PACKAGE_SOURCE"

# Install pre-commit for the vscode user (or current user)
if id "vscode" &>/dev/null; then
    sudo -u vscode bash -c "uv tool install $PACKAGE_SOURCE"
    echo "✅ pre-commit installed for vscode user"
elif [ "$USER" != "root" ]; then
    bash -c "uv tool install $PACKAGE_SOURCE"
    echo "✅ pre-commit installed for $USER"
else
    # For root user, install globally accessible
    bash -c "uv tool install $PACKAGE_SOURCE"
    # Make sure the tool is available in PATH for all users
    if [ -f "/root/.local/bin/pre-commit" ]; then
        ln -sf /root/.local/bin/pre-commit /usr/local/bin/pre-commit
    fi
    echo "✅ pre-commit installed globally"
fi

# Verify installation
echo "Verifying pre-commit installation..."
if command -v pre-commit &> /dev/null; then
    echo "✅ pre-commit command available: $(pre-commit --version)"
else
    echo "⚠️ pre-commit installed but not in PATH - may need container restart"
fi

echo ""
echo "📋 pre-commit Information:"
echo "   Framework for managing and maintaining multi-language pre-commit hooks"
echo "   Use 'pre-commit install' to set up git hooks in your repository"
echo "   Configuration file: .pre-commit-config.yaml"
echo ""

echo "✅ pre-commit feature installation complete!"
