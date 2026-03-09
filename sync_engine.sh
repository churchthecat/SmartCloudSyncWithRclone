#!/usr/bin/env bash
set -e

# ==============================
# SmartCloudSyncWithRclone Sync Engine v2.1
# ==============================

SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
PROJECT_ROOT="$(dirname "$SCRIPT")"

# Config paths
CONFIG_FILE="$PROJECT_ROOT/config/config.sh"
FOLDERS_FILE="$PROJECT_ROOT/config/folders.conf"
EXCLUDE_FILE="$PROJECT_ROOT/config/exclude.conf"

# Load configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ config.sh missing at $CONFIG_FILE"
    exit 1
fi
source "$CONFIG_FILE"

# Validate essential variables
: "${REMOTE:?Missing REMOTE in config.sh}"
: "${HOME_DIR:?Missing HOME_DIR in config.sh}"
: "${TRANSFERS:=4}"      # default
: "${CHECKERS:=8}"       # default
: "${BWLIMIT:=0}"        # unlimited unless set
: "${DELETE:=false}"     # default mirror delete flag
: "${MODE:=live}"        # default live mode

echo "Starting sync..."
echo "Mode: $MODE"
echo

# Read folder mappings: local:remote_sub
while IFS=":" read -r LOCAL REMOTE_SUB; do
    # Skip empty lines and comments
    [[ -z "$LOCAL" || "$LOCAL" =~ ^# ]] && continue

    # Build full local and remote paths
    SRC="$HOME_DIR/$LOCAL"
    DEST="$REMOTE:$REMOTE_SUB"

    # Dry-run mode
    if [[ "$MODE" == "dry-run" ]]; then
        if [[ -d "$SRC" ]]; then
            FILE_COUNT=$(find "$SRC" -type f -size +0c 2>/dev/null | wc -l)
        else
            FILE_COUNT=0
        fi
        echo "[DRYRUN] $SRC -> $DEST ($FILE_COUNT files)"
        continue
    fi

    # Skip missing folders in live mode
    if [[ ! -d "$SRC" ]]; then
        echo "⚠ Skipping missing folder: $SRC"
        continue
    fi

    # Set delete flag if mirror mode enabled
    DELETE_FLAG=""
    [[ "$DELETE" == "true" ]] && DELETE_FLAG="--delete-during"

    echo "Syncing $SRC -> $DEST"

    rclone sync "$SRC" "$DEST" \
        --exclude-from "$EXCLUDE_FILE" \
        --exclude "**/*.nomedia" \
        --min-size 1B \
        --transfers "$TRANSFERS" \
        --checkers "$CHECKERS" \
        --tpslimit 2 \
        $DELETE_FLAG \
        --bwlimit "$BWLIMIT"
done < "$FOLDERS_FILE"

echo
echo "Sync complete"