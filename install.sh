#!/usr/bin/env bash

set -e

echo "Installing SmartCloudSyncWithRclone..."

PROJECT_DIR="$(pwd)"

# Create symlink
sudo ln -sf "$PROJECT_DIR/scripts/main.sh" /usr/local/bin/smartcloud

chmod +x scripts/*.sh
chmod +x install.sh

echo "✔ Binary installed to /usr/local/bin/smartcloud"

# Create systemd folder if needed
mkdir -p ~/.config/systemd/user

echo "Installation complete."
