#!/bin/bash

echo "Installing SmartCloudSyncWithRclone..."

PROJECT_DIR="$(pwd)"

chmod +x scripts/*.sh
chmod +x tools/*.sh

sudo ln -sf "$PROJECT_DIR/scripts/main.sh" /usr/local/bin/smartcloud

echo "Installed."
echo "Run: smartcloud"