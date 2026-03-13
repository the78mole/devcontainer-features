#!/usr/bin/env bash

set -euo pipefail

failed=0

for feature_dir in src/*; do
  [[ -d "${feature_dir}" ]] || continue

  feature=$(basename "${feature_dir}")
  feature_json="${feature_dir}/devcontainer-feature.json"
  feature_readme="${feature_dir}/README.md"

  if [[ ! -f "${feature_json}" || ! -f "${feature_readme}" ]]; then
    continue
  fi

  version=$(jq -r '.version' "${feature_json}")
  if ! [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: ${feature_json} has invalid version '${version}'. Expected X.Y.Z"
    failed=1
    continue
  fi

  major=${version%%.*}
  expected_ref="ghcr.io/the78mole/devcontainer-features/${feature}:${major}"

  refs=$(grep -Eo "ghcr\.io/the78mole/devcontainer-features/${feature}(:[0-9]+)?" "${feature_readme}" || true)

  if [[ -z "${refs}" ]]; then
    echo "ERROR: ${feature_readme} does not contain a feature reference with version tag."
    echo "       Expected to include: ${expected_ref}"
    failed=1
    continue
  fi

  while IFS= read -r ref; do
    [[ -n "${ref}" ]] || continue
    if [[ "${ref}" != "${expected_ref}" ]]; then
      echo "ERROR: ${feature_readme} contains '${ref}', expected '${expected_ref}'"
      failed=1
    fi
  done <<< "${refs}"

done

if [[ "${failed}" -ne 0 ]]; then
  exit 1
fi

echo "Feature version references in README files are consistent."
