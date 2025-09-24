#!/bin/bash
set -e

# Parse input arguments
VERSION=${VERSION:-"latest"}

echo "Installing pre-commit framework..."

# Check if Python is available (required for pre-commit)
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
    echo "Installing uv (Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh

    # Move uv to global location to avoid permission issues
    if [ -f "$HOME/.cargo/bin/uv" ]; then
        mv "$HOME/.cargo/bin/uv" /usr/local/bin/uv 2>/dev/null || cp "$HOME/.cargo/bin/uv" /usr/local/bin/uv
    elif [ -f "$HOME/.local/bin/uv" ]; then
        mv "$HOME/.local/bin/uv" /usr/local/bin/uv 2>/dev/null || cp "$HOME/.local/bin/uv" /usr/local/bin/uv
    fi

    # Ensure permissions are correct
    chmod +x /usr/local/bin/uv
    chown root:root /usr/local/bin/uv

    # Add to PATH for all users
    echo "export PATH=\"/usr/local/bin:\$PATH\"" >> /etc/bash.bashrc
    echo "✅ uv installed successfully"
    uv --version
fi

# Final verification that uv is available
if ! command -v uv &> /dev/null; then
    echo "❌ uv command not found in PATH after installation"
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

# Install pre-commit for the vscode user (or current user)
if id "vscode" &>/dev/null; then
    sudo -u vscode uv tool install "$PACKAGE_SOURCE"
    echo "✅ pre-commit installed for vscode user"
elif [ "$USER" != "root" ]; then
    uv tool install "$PACKAGE_SOURCE"
    echo "✅ pre-commit installed for $USER"
else
    # For root user, install globally accessible
    uv tool install "$PACKAGE_SOURCE"
    # Make sure the tool is available in PATH for all users
    if [ -f "/root/.local/bin/pre-commit" ]; then
        ln -sf /root/.local/bin/pre-commit /usr/local/bin/pre-commit
    fi
    echo "✅ pre-commit installed globally"
fi

# Verify pre-commit installation
if command -v pre-commit &> /dev/null; then
    echo "✅ pre-commit available: $(pre-commit --version)"
else
    # For root user, install globally accessible
    bash -c "export PATH=\"/root/.local/bin:/usr/local/bin:\$PATH\" && uv tool install $PACKAGE_SOURCE"
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
