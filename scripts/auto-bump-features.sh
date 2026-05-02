#!/usr/bin/env bash

# Auto-bumps version for features that have changes since their last release tag.
# Designed to run as a pre-commit hook: modifies and stages files automatically.
#
# Version calculation:
#   - Uses `cog bump --dry-run` when committed conventional commits are available.
#   - Falls back to a patch bump when only staged (uncommitted) changes exist.
#
# Files updated per feature:
#   - src/<feature>/devcontainer-feature.json  (.version field)
#   - src/<feature>/README.md                  (major version in ghcr.io references)

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

bumped=0

for feature_dir in src/*/; do
  [[ -d "${feature_dir}" ]] || continue

  feature=$(basename "${feature_dir}")
  feature_json="${feature_dir}devcontainer-feature.json"
  feature_readme="${feature_dir}README.md"

  [[ -f "${feature_json}" ]] || continue

  current_version=$(jq -r '.version' "${feature_json}")
  tag="${feature}/v${current_version}"

  # Only act when the current version is already released (tag exists).
  # If no tag exists, the feature is new and the version was set manually.
  git rev-parse -q --verify "refs/tags/${tag}" >/dev/null 2>&1 || continue

  # Check for changes since the last tag (committed or currently staged).
  committed_changes=$(git diff --name-only "${tag}" HEAD -- "${feature_dir}" 2>/dev/null || true)
  staged_changes=$(git diff --cached --name-only -- "${feature_dir}" 2>/dev/null || true)
  [[ -n "${committed_changes}" || -n "${staged_changes}" ]] || continue

  # --- Calculate next version ---
  # Ask cog based on already-committed conventional commits since the tag.
  next_tag=$(cog bump --package "${feature}" --auto --dry-run --skip-untracked 2>/dev/null \
    | grep -E "^${feature}/v" | tail -1 || true)

  if [[ -n "${next_tag}" ]]; then
    next_version="${next_tag#"${feature}"/v}"
  else
    # No committed conventional commits yet (only staged changes) → patch bump.
    IFS='.' read -r maj min pat <<< "${current_version}"
    next_version="${maj}.${min}.$((pat + 1))"
  fi

  [[ "${next_version}" != "${current_version}" ]] || continue

  current_major="${current_version%%.*}"
  next_major="${next_version%%.*}"

  echo -e "${CYAN}${BOLD}↑ ${feature}${RESET}: ${current_version} → ${BOLD}${next_version}${RESET}"

  # Update .version in devcontainer-feature.json.
  jq --arg v "${next_version}" '.version = $v' "${feature_json}" > /tmp/cog-auto-bump.json
  mv /tmp/cog-auto-bump.json "${feature_json}"
  git add "${feature_json}"

  # Update major-version references in README.md when the major changed.
  if [[ -f "${feature_readme}" && "${next_major}" != "${current_major}" ]]; then
    echo -e "  ${YELLOW}Major bump: updating README references :${current_major} → :${next_major}${RESET}"
    sed -i \
      "s|ghcr\.io/the78mole/devcontainer-features/${feature}:${current_major}|ghcr.io/the78mole/devcontainer-features/${feature}:${next_major}|g" \
      "${feature_readme}"
    git add "${feature_readme}"
  fi

  bumped=1
done

if [[ "${bumped}" -eq 1 ]]; then
  echo -e "${GREEN}${BOLD}✓ Version bumps staged.${RESET}"
fi
