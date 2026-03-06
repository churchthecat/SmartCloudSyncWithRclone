#!/usr/bin/env bash

set -e

VERSION="v1.3.0"

# ---- Detect real project root ----
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

LOCKFILE="/tmp/smartcloud.lock"

# ---- Lock Protection (with stale cleanup) ----
if [[ -f "$LOCKFILE" ]]; then
    OLD_PID=$(cat "$LOCKFILE")
    if ! kill -0 "$OLD_PID" 2>/dev/null; then
        echo "⚠ Removing stale lock..."
        rm -f "$LOCKFILE"
    else
        echo "⚠ SmartCloud already running (PID $OLD_PID). Exiting."
        exit 1
    fi
fi

echo $$ > "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

COMMAND=$1
MODE="live"

if [[ "$2" == "--mode" ]]; then
    MODE="$3"
fi

if [[ "$1" == "--mode" ]]; then
    MODE="$2"
fi

echo "SmartCloudSyncWithRclone Version: $VERSION"
echo "PROJECT ROOT = $PROJECT_ROOT"

case "$COMMAND" in

sync)
    echo "Starting sync in mode: $MODE"

    # Auto bandwidth detection (simple implementation)
    SPEED_TEST=$(ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo "online" || echo "offline")

    if [[ "$SPEED_TEST" == "online" ]]; then
        BW_LIMIT="--bwlimit 0"
    else
        BW_LIMIT="--bwlimit 2M"
    fi

    export BW_LIMIT

    bash "$PROJECT_ROOT/sync_engine.sh"
    ;;

status)
    echo "---- SmartCloud Status ----"
    echo "Lockfile:"
    ls -l /tmp/smartcloud.lock 2>/dev/null || echo "No lock"

    echo
    echo "Active timers:"
    systemctl --user list-timers | grep smartcloud || echo "No timer"

    echo
    echo "Running processes:"
    ps aux | grep rclone | grep -v grep || echo "No rclone running"

    echo
    echo "Last log entries:"
    tail -n 20 ~/smartcloud.log 2>/dev/null || echo "No log"

    ;;

version)
    echo "$VERSION"
    ;;

bump)
    echo "Bumping version..."
    NEW_TAG="v1.3.$(date +%s)"
    git tag "$NEW_TAG"
    git push origin "$NEW_TAG"
    echo "New version tagged: $NEW_TAG"
    ;;

*)
    echo
    echo "Usage:"
    echo "  smartcloud sync"
    echo "  smartcloud sync --mode both"
    echo "  smartcloud status"
    echo "  smartcloud bump"
    echo "  smartcloud version"
    echo
    exit 1
    ;;
esac