#!/bin/bash

# upgrade-hugo.sh
# Automatically update Hugo version in README.md and netlify.toml

set -e

# Get current Hugo version
DETECTED_VERSION=$(hugo version | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/^v//')

if [ -z "$DETECTED_VERSION" ]; then
    echo "Error: Could not detect Hugo version"
    exit 1
fi

echo "Detected Hugo version: $DETECTED_VERSION"
read -p "Use this version? (y/n): " use_detected

if [[ "$use_detected" =~ ^[Yy]$ ]]; then
    HUGO_VERSION="$DETECTED_VERSION"
else
    read -p "Enter Hugo version (e.g., 0.139.3): " HUGO_VERSION

    # Validate version format
    if ! [[ "$HUGO_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Invalid version format. Expected format: X.Y.Z (e.g., 0.139.3)"
        exit 1
    fi

    echo "Using Hugo version: $HUGO_VERSION"
fi

# Get repository root directory
REPO_ROOT=$(git rev-parse --show-toplevel)

# Files to update
README_FILE="$REPO_ROOT/README.md"
NETLIFY_FILE="$REPO_ROOT/netlify.toml"

# Backup files
cp "$README_FILE" "$README_FILE.bak"
cp "$NETLIFY_FILE" "$NETLIFY_FILE.bak"

echo "Updating files..."

# Update README.md
sed -i.tmp "s/hugo-v[0-9]+\.[0-9]+\.[0-9]+-ff4088/hugo-v$HUGO_VERSION-ff4088/g" "$README_FILE"
rm -f "$README_FILE.tmp"

# Update netlify.toml
sed -i.tmp "s/HUGO_VERSION = \"[0-9]+\.[0-9]+\.[0-9]+\"/HUGO_VERSION = \"$HUGO_VERSION\"/g" "$NETLIFY_FILE"
rm -f "$NETLIFY_FILE.tmp"

# Remove backups
rm -f "$README_FILE.bak" "$NETLIFY_FILE.bak"

echo "✅ Updated Hugo version to $HUGO_VERSION in:"
echo "   - README.md"
echo "   - netlify.toml"

# Show git diff
echo ""
echo "Changes:"
git diff "$README_FILE" "$NETLIFY_FILE"
