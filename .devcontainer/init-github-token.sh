#!/bin/bash
set -e

# Initialize GITHUB_TOKEN on host before container starts.
# The token is written to /tmp (bind-mounted into the container) so that
# postCreateCommand can configure gh auth inside the container without
# requiring keyring access (which is unavailable in the container).

TOKEN_FILE="/tmp/.gh_devcontainer_token"

get_token() {
    if [ -n "$GITHUB_TOKEN" ]; then
        echo "$GITHUB_TOKEN"
        return
    fi
    if command -v gh &> /dev/null && gh auth status &> /dev/null 2>&1; then
        gh auth token 2>/dev/null || true
    fi
}

TOKEN=$(get_token)

if [ -n "$TOKEN" ]; then
    printf '%s' "$TOKEN" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
    echo "✓ Token written to $TOKEN_FILE for container gh auth setup"
else
    echo "⚠️  Warning: GITHUB_TOKEN not available on host. Run 'gh auth login' or set GITHUB_TOKEN manually."
fi
