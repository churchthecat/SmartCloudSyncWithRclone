#!/bin/bash

# ==========================================================
# SmartCloudSyncWithRclone - Sync Engine
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

CONFIG_FILE="$PROJECT_ROOT/config/config.sh"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Missing config/config.sh"
    exit 1
fi

source "$CONFIG_FILE"

# ===== Logging Setup =====
mkdir -p "$(dirname "$LOGFILE")"
exec > >(tee -a "$LOGFILE") 2>&1

echo "----------------------------------------"
echo "Starting SmartCloud sync"
echo "Mode: $SYNC_MODE"
echo "Remote: $REMOTE:$REMOTE_BASE_PATH"
echo "Time: $(date)"
echo "----------------------------------------"

# ===== Bandwidth Detection =====
# Simple fallback logic (can improve later)
UPLOAD_SPEED_MBIT=$(cat /sys/class/net/*/speed 2>/dev/null | head -n1)

if [ -z "$UPLOAD_SPEED_MBIT" ]; then
    UPLOAD_SPEED_MBIT=100
fi

if [ "$UPLOAD_SPEED_MBIT" -gt 100 ]; then
    LIMIT_PERCENT=$FAST_PERCENT
elif [ "$UPLOAD_SPEED_MBIT" -gt 20 ]; then
    LIMIT_PERCENT=$NORMAL_PERCENT
else
    LIMIT_PERCENT=20
fi

BW_LIMIT="$((UPLOAD_SPEED_MBIT * LIMIT_PERCENT / 100))M"

echo "Detected link speed: ${UPLOAD_SPEED_MBIT} Mbit"
echo "Using bandwidth limit: $BW_LIMIT"

# ===== Paths =====
LOCAL_PATH="$HOME"
REMOTE_PATH="$REMOTE:$REMOTE_BASE_PATH"

# ===== Sync Logic =====
case "$SYNC_MODE" in
    live)
        echo "Running LIVE sync..."
        rclone sync "$LOCAL_PATH" "$REMOTE_PATH/live" \
            --bwlimit "$BW_LIMIT" \
            -P
        ;;
    backup)
        echo "Running BACKUP copy..."
        rclone copy "$LOCAL_PATH" "$REMOTE_PATH/backup" \
            --bwlimit "$BW_LIMIT" \
            -P
        ;;
    both)
        echo "Running LIVE sync..."
        rclone sync "$LOCAL_PATH" "$REMOTE_PATH/live" \
            --bwlimit "$BW_LIMIT" \
            -P

        echo "Running BACKUP copy..."
        rclone copy "$LOCAL_PATH" "$REMOTE_PATH/backup" \
            --bwlimit "$BW_LIMIT" \
            -P
        ;;
    *)
        echo "Unknown SYNC_MODE"
        exit 1
        ;;
esac

echo "Sync finished at $(date)"
echo ""