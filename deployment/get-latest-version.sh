#!/bin/bash
# get-latest-version.sh: Gets the latest version from GitHub Actions artifacts
# Usage: ./get-latest-version.sh <github-username> <repo-name> <github-token>
# Example: ./get-latest-version.sh jcernei cloud-app ghp_123456789abcdef

# This is a simplified example - in a real environment, you might want to use the GitHub API
# to automatically fetch the latest version artifact

echo "IMPORTANT: To use this script properly, you need to:"
echo "1. Download the 'version.txt' artifact from your latest successful GitHub Actions run"
echo "2. Use the version number inside to deploy that specific version"
echo ""
echo "For now, manually check your GitHub Actions runs at:"
echo "https://github.com/$1/$2/actions"
echo ""
echo "After downloading and extracting the version file, deploy with:"
echo "./deployment/deploy-version.sh $1 \$(cat path/to/version.txt)"
