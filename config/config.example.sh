#!/usr/bin/env bash

# --------------------------
# Remote Settings
# --------------------------

# Rclone remote name (replace with your cloud remote)
REMOTE="my_remote:"

# Local root directory to sync from
HOME_DIR="/home/user"

# --------------------------
# Sync Settings
# --------------------------

# Number of simultaneous transfers
TRANSFERS=4

# Number of checkers for rclone
CHECKERS=8

# Bandwidth limit (0 = unlimited, e.g., "1M" = 1 MB/s)
BWLIMIT="0"

# Enable mirror delete? true/false
DELETE=false

# Sync mode: "live" or "dry-run"
MODE="live"

# Path to exclude file (patterns of files/folders to skip)
EXCLUDE_FILE="$HOME_DIR/code/SmartCloudSyncWithRclone/config/exclude.conf"