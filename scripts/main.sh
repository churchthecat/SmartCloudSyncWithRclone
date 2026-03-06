#!/usr/bin/env bash

set -e

VERSION="v1.2.0"

# Resolve project root (one directory above scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "SmartCloudSyncWithRclone Version: $VERSION"
echo "PROJECT ROOT = $PROJECT_ROOT"

COMMAND=$1
MODE="live"

# Parse arguments
if [[ "$2" == "--mode" ]]; then
    MODE="$3"
fi

if [[ "$1" == "--mode" ]]; then
    MODE="$2"
fi

case "$COMMAND" in

sync)

    echo "Starting sync in mode: $MODE"

    if [[ "$MODE" == "both" ]]; then
        echo "Running LIVE + BACKUP sync..."
    else
        echo "Running LIVE sync..."
    fi

    bash "$PROJECT_ROOT/sync_engine.sh"

    ;;

version)

    echo "$VERSION"

    ;;

*)

    echo
    echo "Usage:"
    echo "  smartcloud sync"
    echo "  smartcloud sync --mode both"
    echo "  smartcloud version"
    echo
    exit 1

    ;;

esac