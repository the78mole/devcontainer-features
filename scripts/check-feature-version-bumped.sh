#!/usr/bin/env bash

# Checks that any feature with changes since its last release tag has a bumped
# version. Mirrors the tag-based detection logic used in the release workflow.

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

failed=0

for feature_dir in src/*; do
  [[ -d "${feature_dir}" ]] || continue

  feature=$(basename "${feature_dir}")
  feature_json="${feature_dir}/devcontainer-feature.json"

  if [[ ! -f "${feature_json}" ]]; then
    continue
  fi

  current_version=$(jq -r '.version' "${feature_json}")
  tag="${feature}/v${current_version}"

  # If no tag exists for the current version, a release is already planned.
  if ! git rev-parse -q --verify "refs/tags/${tag}" >/dev/null 2>&1; then
    continue
  fi

  # Tag exists – check for committed or staged changes since the tag.
  committed_changes=$(git diff --name-only "${tag}" HEAD -- "${feature_dir}" 2>/dev/null || true)
  staged_changes=$(git diff --cached --name-only -- "${feature_dir}" 2>/dev/null || true)

  if [[ -n "${committed_changes}" || -n "${staged_changes}" ]]; then
    echo ""
    echo -e "${RED}${BOLD}ERROR${RESET} ${BOLD}Feature '${CYAN}${feature}${RESET}${BOLD}' has unreleased changes (tag: ${tag}, version: ${current_version})${RESET}"
    echo -e "      ${YELLOW}Please bump the version in '${feature_json}'.${RESET}"
    echo -e "      ${DIM}Commits since '${tag}':${RESET}"
    git log --oneline "${tag}..HEAD" -- "${feature_dir}" 2>/dev/null \
      | sed "s/^\([a-f0-9]*\) \(.*\)/${DIM}  - ${RESET}${CYAN}\1${RESET} \2/"
    failed=1
  fi
done

if [[ "${failed}" -ne 0 ]]; then
  echo ""
  exit 1
fi

echo -e "${BOLD}All changed features have appropriate version bumps.${RESET}"
