#!/usr/bin/env bash
# SmartCloudSyncWithRclone v2.3.1
# Adds validation + safety protections

VERSION="2.3.1"
LOCK_FILE="/tmp/smartcloud.lock"

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$PROJECT_ROOT/config/folders.conf"
VALIDATOR="$PROJECT_ROOT/validator.sh"

MODE="live"
EXTRA_ARGS=""
REMOTE="internxt"

# -----------------------------
# Parse arguments
# -----------------------------
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
echo "SmartCloudSyncWithRclone v$VERSION"
echo "Started: $(date)"
echo "PROJECT ROOT = $PROJECT_ROOT"
echo "================================"
echo
echo "Mode: $MODE"
echo

# -----------------------------
# Lockfile protection
# -----------------------------
if [[ -f "$LOCK_FILE" ]]; then
    echo "⚠ Another sync is already running."
    exit 1
fi

trap 'rm -f "$LOCK_FILE"' EXIT
touch "$LOCK_FILE"

# -----------------------------
# Config validation
# -----------------------------
if [[ ! -x "$VALIDATOR" ]]; then
    echo "❌ validator.sh missing or not executable"
    exit 1
fi

"$VALIDATOR" || exit 1

# -----------------------------
# Check folders config
# -----------------------------
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Missing folders.conf"
    exit 1
fi

TOTAL=$(grep -v '^#' "$CONFIG_FILE" | grep -v '^$' | wc -l)
COUNT=0

# -----------------------------
# Main loop
# -----------------------------
grep -v '^#' "$CONFIG_FILE" | grep -v '^$' | while IFS=":" read -r SRC DEST; do

    [[ -z "$SRC" ]] && continue
    [[ -z "$DEST" ]] && continue

    COUNT=$((COUNT+1))

    echo
    echo "Folder [$COUNT/$TOTAL]"
    echo "$SRC -> $DEST"
    echo

    LOCAL_SRC="$HOME/$SRC"

    if [[ ! -d "$LOCAL_SRC" ]]; then
        echo "⚠ Skipping $SRC: folder not found"
        continue
    fi

    DRY=""
    [[ "$MODE" == "dry-run" ]] && DRY="--dry-run"

    # -----------------------------
    # Mass delete protection
    # -----------------------------
    if [[ "$MODE" != "dry-run" ]]; then
        echo "🔍 Checking for dangerous deletions..."

        DELETE_COUNT=$(rclone sync \
            "$LOCAL_SRC" "$REMOTE:$DEST" \
            --dry-run \
            --delete-during \
            --min-size 1b 2>&1 | grep -c "Deleting")

        if [[ $DELETE_COUNT -gt 50 ]]; then
            echo "❌ Too many deletions detected ($DELETE_COUNT). Aborting."
            exit 1
        fi
    fi

    # -----------------------------
    # Run sync
    # -----------------------------
    rclone sync \
        "$LOCAL_SRC" "$REMOTE:$DEST" \
        --progress \
        --fast-list \
        --transfers 3 \
        --checkers 2 \
        --tpslimit 5 \
        --retries 3 \
        --low-level-retries 5 \
        --delete-during \
        --min-size 1b \
        $DRY \
        $EXTRA_ARGS

done

echo
echo "✅ Sync complete"
