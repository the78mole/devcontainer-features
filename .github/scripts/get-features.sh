#!/bin/bash

# Script to dynamically discover all features for CI matrix
set -e

# Function to get features from src directory
get_features() {
    local features=()

    # Check if src directory exists
    if [[ -d "src" ]]; then
        # Find all directories in src that contain devcontainer-feature.json
        while IFS= read -r -d '' feature_dir; do
            feature_name=$(basename "$feature_dir")
            features+=("$feature_name")
        done < <(find src -mindepth 1 -maxdepth 1 -type d -exec test -f {}/devcontainer-feature.json \; -print0)
    fi

    # Output as JSON array (compact format)
    printf '%s\n' "${features[@]}" | jq -R . | jq -s -c .
}

# Call the function
get_features
