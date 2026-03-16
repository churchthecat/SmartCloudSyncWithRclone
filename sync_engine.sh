#!/usr/bin/env bash
# SmartCloudSyncWithRclone v2.2
# Skips all empty files automatically

VERSION="2.2"
LOCK_FILE="/tmp/smartcloud.lock"

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$PROJECT_ROOT/config/folders.conf"

MODE="live"
EXTRA_ARGS=""
REMOTE="internxt"  # Change if you use another rclone remote

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

    # Local source path (folders live in home)
    LOCAL_SRC="$HOME/$SRC"

    # Skip folder if missing
    if [[ ! -d "$LOCAL_SRC" ]]; then
        echo "Skipping $SRC: folder not found"
        continue
    fi

    # Dry-run option
    DRY=""
    [[ "$MODE" == "dry-run" ]] && DRY="--dry-run"

    # Run rclone, skipping all empty files using --min-size 1b
    rclone sync \
        "$LOCAL_SRC" "$REMOTE:$DEST" \
        --progress \
        --fast-list \
        --transfers 4 \
        --checkers 8 \
        --delete-during \
        $DRY \
        $EXTRA_ARGS \
        --min-size 1b

done

echo
echo "Sync complete"