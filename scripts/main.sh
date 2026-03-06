#!/usr/bin/env bash

set -e

VERSION="v1.2.0"

# ---- Detect real project root ----
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

LOCKFILE="/tmp/smartcloud.lock"

# ---- Lock protection ----
if [[ -f "$LOCKFILE" ]]; then
    echo "⚠ SmartCloud already running. Exiting."
    exit 1
fi

trap "rm -f $LOCKFILE" EXIT
touch "$LOCKFILE"

echo "SmartCloudSyncWithRclone Version: $VERSION"
echo "PROJECT ROOT = $PROJECT_ROOT"

COMMAND=$1
MODE="live"

# ---- Argument parsing ----
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