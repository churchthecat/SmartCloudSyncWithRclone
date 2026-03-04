#!/bin/bash

VERSION=$(cat VERSION)

echo "Building release v$VERSION..."

RELEASE_DIR="release/v$VERSION"
mkdir -p "$RELEASE_DIR"

cp -r . "$RELEASE_DIR"

tar -czf "release/SmartCloudSyncWithRclone-$VERSION.tar.gz" -C release "v$VERSION"

echo "Release created."