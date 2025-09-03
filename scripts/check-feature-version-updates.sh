#!/bin/bash

# Script to check if feature versions were updated when feature files are modified
# This ensures proper versioning when features are changed

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get list of staged files
staged_files=$(git diff --cached --name-only)

# Function to get current version from Git HEAD
get_current_version() {
    local feature_json="$1"
    if git show "HEAD:$feature_json" >/dev/null 2>&1; then
        git show "HEAD:$feature_json" | python3 -c "import json, sys; print(json.load(sys.stdin).get('version', 'unknown'))" 2>/dev/null || echo "unknown"
    else
        echo "new-file"
    fi
}

# Function to check if feature has changes other than just version updates
has_feature_changes() {
    local feature_path="$1"

    # Check if any files in the feature directory are staged
    while IFS= read -r file; do
        if [[ "$file" == "$feature_path"* ]]; then
            return 0  # Has changes
        fi
    done <<< "$staged_files"

    return 1  # No changes
}

# Function to check if version was updated in staged changes
version_was_updated() {
    local feature_json="$1"

    if echo "$staged_files" | grep -q "^$feature_json$"; then
        # Check if version line was modified in staged changes
        git diff --cached "$feature_json" | grep -q -E '^[+-].*"version"'
        return $?
    fi

    return 1  # Version was not updated
}

# Function to get old and new version from diff
get_version_change() {
    local feature_json="$1"
    local version_lines
    version_lines=$(git diff --cached "$feature_json" | grep -E '^[+-].*"version"')

    local old_version new_version
    old_version=$(echo "$version_lines" | grep '^-' | sed -E 's/.*"version":[[:space:]]*"([^"]+)".*/\1/')
    new_version=$(echo "$version_lines" | grep '^+' | sed -E 's/.*"version":[[:space:]]*"([^"]+)".*/\1/')

    echo "$old_version → $new_version"
}

echo "🔍 Checking feature version updates..."

# Track if any issues were found
issues_found=false

# Get all feature directories
for feature_dir in src/*/; do
    if [ -d "$feature_dir" ]; then
        feature_name=$(basename "$feature_dir")
        feature_json="${feature_dir}devcontainer-feature.json"

        # Skip if feature.json doesn't exist
        if [ ! -f "$feature_json" ]; then
            continue
        fi

        # Check if this feature has any changes
        if has_feature_changes "$feature_dir"; then
            # Check if version was updated
            if ! version_was_updated "$feature_json"; then
                current_version=$(get_current_version "$feature_json")
                echo -e "${RED}❌ Feature '$feature_name' has changes but version was not updated!${NC}"
                echo -e "   Current version in Git: $current_version"
                echo -e "   Please update the version in $feature_json"

                # Suggest next version based on current version
                if [[ "$current_version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
                    major="${BASH_REMATCH[1]}"
                    minor="${BASH_REMATCH[2]}"
                    patch="${BASH_REMATCH[3]}"

                    next_patch="$major.$minor.$((patch + 1))"
                    next_minor="$major.$((minor + 1)).0"
                    next_major="$((major + 1)).0.0"

                    echo -e "   ${YELLOW}Suggested versions:${NC}"
                    echo -e "     - Bug fix: $next_patch"
                    echo -e "     - New feature: $next_minor"
                    echo -e "     - Breaking change: $next_major"
                fi

                echo ""
                issues_found=true
            else
                # Get the version change
                version_change=$(get_version_change "$feature_json")
                echo -e "${GREEN}✅ Feature '$feature_name' version updated: $version_change${NC}"
            fi
        fi
    fi
done

if [ "$issues_found" = true ]; then
    echo ""
    echo -e "${RED}❌ Version check failed!${NC}"
    echo -e "${YELLOW}💡 When you modify a feature, please also update its version in devcontainer-feature.json${NC}"
    echo -e "${YELLOW}   This ensures proper versioning and helps users track changes.${NC}"
    echo ""
    echo "Examples of version updates:"
    echo "  - Bug fixes: 1.0.0 → 1.0.1"
    echo "  - New features: 1.0.0 → 1.1.0"
    echo "  - Breaking changes: 1.0.0 → 2.0.0"
    exit 1
else
    echo -e "${GREEN}✅ All feature version checks passed!${NC}"
fi
