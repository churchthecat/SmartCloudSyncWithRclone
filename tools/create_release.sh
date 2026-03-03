#!/usr/bin/env bash

set -e

VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")

echo "Creating release package for $VERSION"

RELEASE_DIR="release"
PACKAGE_NAME="SmartCloudSyncWithRclone-$VERSION"

rm -rf $RELEASE_DIR
mkdir -p $RELEASE_DIR/$PACKAGE_NAME

cp -r scripts config tools README.md install.sh $RELEASE_DIR/$PACKAGE_NAME 2>/dev/null || true

cd $RELEASE_DIR

tar -czf "$PACKAGE_NAME.tar.gz" "$PACKAGE_NAME"
sha256sum "$PACKAGE_NAME.tar.gz" > "$PACKAGE_NAME.sha256"

echo "✔ Release created in $RELEASE_DIR"
