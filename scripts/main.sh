#!/usr/bin/env bash

# Resolve real script path even if called via symlink
SCRIPT="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT")"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

VERSION=$(cat "$PROJECT_ROOT/VERSION")

echo "SmartCloudSyncWithRclone Version: $VERSION"
echo "PROJECT ROOT = $PROJECT_ROOT"

MODE="live"

if [[ "$1" == "--dry-run" ]]; then
    MODE="dry-run"
fi

export MODE
export PROJECT_ROOT

bash "$PROJECT_ROOT/sync_engine.sh"
