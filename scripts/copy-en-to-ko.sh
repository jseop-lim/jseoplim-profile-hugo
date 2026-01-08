#!/bin/bash

copy_if_missing_or_different() {
  local root_dir="$1"
  local en_name="$2"
  local ko_name="$3"

  if [[ ! -d "$root_dir" ]]; then
    echo "$root_dir directory not found"
    return 1
  fi

  find "$root_dir" -name "$en_name" -type f | while read -r file; do
    local target
    target="${file%$en_name}$ko_name"

    if [[ ! -f "$target" ]]; then
      cp "$file" "$target"
      echo "Copied to $target"
    elif ! cmp -s "$file" "$target"; then
      cp "$file" "$target"
      echo "Copied to $target"
    fi
  done
}

copy_if_missing_or_different "content/posts" "index.en.md" "index.ko.md"
copy_if_missing_or_different "content/categories" "_index.en.md" "_index.ko.md"
copy_if_missing_or_different "content/tags" "_index.en.md" "_index.ko.md"

echo "File synchronization completed."
