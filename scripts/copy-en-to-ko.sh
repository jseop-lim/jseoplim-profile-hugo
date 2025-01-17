#!/bin/bash

# Navigate to the content/posts directory
cd content/posts || { echo "content/posts directory not found"; exit 1; }

# Find all index.en.md files and copy them to index.ko.md if they differ
find . -name 'index.en.md' | while read -r file; do
  # Create the target file name by replacing '.en.md' with '.ko.md'
  target="${file%.en.md}.ko.md"
  
  # Check if the target file exists and is different from the source file
  if [[ ! -f "$target" ]]; then
    cp "$file" "$target"
    echo "Copied to $target"
  elif ! cmp -s "$file" "$target"; then
    cp "$file" "$target"
    echo "Copied to $target"
  fi
done

echo "File synchronization completed."