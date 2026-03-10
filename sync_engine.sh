#!/usr/bin/env bash
# SmartCloudSyncWithRclone

VERSION="2.2"
LOCK_FILE="/tmp/smartcloud.lock"

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$PROJECT_ROOT/config/folders.conf"

MODE="live"
EXTRA_ARGS=""
REMOTE="internxt"  # Change this if you use another rclone remote

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --extra)
            EXTRA_ARGS="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

echo
echo "================================"
echo "SmartCloudSyncWithRclone"
echo "Started: $(date)"
echo "PROJECT ROOT = $PROJECT_ROOT"
echo "================================"
echo
echo "Mode: $MODE"
echo

# Lockfile handling
if [[ -f "$LOCK_FILE" ]]; then
    echo "⚠ Another sync is already running."
    exit 1
fi
trap 'rm -f "$LOCK_FILE"' EXIT
touch "$LOCK_FILE"

# Check configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Missing folders.conf"
    exit 1
fi

# Count valid folders
TOTAL=$(grep -v '^#' "$CONFIG_FILE" | grep -v '^$' | wc -l)
COUNT=0

# Process each folder
grep -v '^#' "$CONFIG_FILE" | grep -v '^$' | while IFS=":" read -r SRC DEST; do

    [[ -z "$SRC" ]] && continue
    [[ -z "$DEST" ]] && continue

    COUNT=$((COUNT+1))

    echo
    echo "Folder [$COUNT/$TOTAL]"
    echo "$SRC -> $DEST"
    echo

    # Determine local source path
    if [[ "$SRC" = /* ]]; then
        LOCAL_SRC="$SRC"
    else
        LOCAL_SRC="$HOME/$SRC"
    fi

    # Dry-run option
    if [[ "$MODE" == "dry-run" ]]; then
        DRY="--dry-run"
    else
        DRY=""
    fi

    # Run rclone sync
    rclone sync \
        "$LOCAL_SRC" "$REMOTE:$DEST" \
        --progress \
        --fast-list \
        --transfers 4 \
        --checkers 8 \
        --delete-during \
        $DRY \
        $EXTRA_ARGS

done

echo
echo "Sync complete"