#!/usr/bin/env bash

set -e

FILE="VERSION"

if [[ -z "$1" ]]; then
    echo "Usage: $0 <new-version>"
    exit 1
fi

NEW_VERSION="$1"

echo "$NEW_VERSION" > $FILE

# Update all scripts
grep -rl 'VERSION=' . | while read -r file; do
    sed -i "s/VERSION=.*/VERSION=\"$NEW_VERSION\"/g" "$file"
done

echo "Version bumped to $NEW_VERSION"
