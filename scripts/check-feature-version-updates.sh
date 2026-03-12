#!/bin/bash

# Feature versioning is now automated via <feature>/vX.Y.Z git tags.
# The paulhatch/semver GitHub Action in the release workflow creates these tags
# automatically when changes are detected in src/<feature>/ or test/<feature>/.
#
# Manual updates to the "version" field in devcontainer-feature.json are no
# longer required for version tracking purposes.

echo "ℹ️  Feature versions are now tracked via <feature>/vX.Y.Z git tags."
echo "   The release workflow automatically creates tags using paulhatch/semver"
echo "   when changes are detected in src/<feature>/ or test/<feature>/."
echo "   No manual version updates in devcontainer-feature.json are needed."
