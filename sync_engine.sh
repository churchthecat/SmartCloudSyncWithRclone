#!/usr/bin/env bash
# SmartCloudSyncWithRclone v2.4.4 (STABLE)

set -euo pipefail

VERSION="2.4.4"
LOCK_FILE="/tmp/smartcloud.lock"

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$PROJECT_ROOT/config/folders.conf"
VALIDATOR="$PROJECT_ROOT/validator.sh"
LOG_DIR="$PROJECT_ROOT/logs"
EXCLUDES_FILE="$PROJECT_ROOT/config/exclude.conf"

MODE="live"
EXTRA_ARGS=""
REMOTE="internxt"

# Performance tuning (stable defaults)
PARALLEL_JOBS=2
TRANSFERS=2
CHECKERS=1
TPSLIMIT=5

mkdir -p "$LOG_DIR"

# -----------------------------
# Parse arguments
# -----------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode) MODE="$2"; shift 2 ;;
        --extra) EXTRA_ARGS="$2"; shift 2 ;;
        --parallel) PARALLEL_JOBS="$2"; shift 2 ;;
        *) shift ;;
    esac
done

echo
echo "================================"
echo "SmartCloudSyncWithRclone v$VERSION"
echo "Started: $(date)"
echo "================================"
echo "Mode: $MODE | Parallel: $PARALLEL_JOBS"
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
# Validation
# -----------------------------
[[ ! -x "$VALIDATOR" ]] && echo "❌ validator.sh missing" && exit 1
"$VALIDATOR" || exit 1

[[ ! -f "$CONFIG_FILE" ]] && echo "❌ Missing folders.conf" && exit 1

if [[ -f "$EXCLUDES_FILE" ]]; then
    EXCLUDES_ARG="--exclude-from=$EXCLUDES_FILE"
else
    echo "⚠ exclude.conf not found — continuing without excludes"
    EXCLUDES_ARG=""
fi

# -----------------------------
# Sync function (stable)
# -----------------------------
run_sync() {
    local SRC="$1"
    local DEST="$2"

    local LOCAL_SRC="$HOME/$SRC"
    local LOG_FILE="$LOG_DIR/$(echo "$SRC" | tr '/' '_').log"

    echo "▶ Sync: $SRC -> $DEST"
    echo "📄 Log: $LOG_FILE"

    if [[ ! -d "$LOCAL_SRC" ]]; then
        echo "⚠ Missing: $SRC"
        return
    fi

    local DRY=""
    [[ "$MODE" == "dry-run" ]] && DRY="--dry-run"

    local CURRENT_TPS="$TPSLIMIT"

    # -----------------------------
    # Sync with retries
    # -----------------------------
    local ATTEMPT=1
    local MAX_ATTEMPTS=3

    while [[ "$ATTEMPT" -le "$MAX_ATTEMPTS" ]]; do
        echo "Attempt $ATTEMPT..."

        rclone sync \
            "$LOCAL_SRC" "$REMOTE:$DEST" \
            --fast-list \
            --size-only \
            --check-first \
            $EXCLUDES_ARG \
            --max-delete 100 \
            --min-age 10s \
            --transfers "$TRANSFERS" \
            --checkers "$CHECKERS" \
            --tpslimit "$CURRENT_TPS" \
            --retries 3 \
            --low-level-retries 5 \
            --delete-during \
            --stats 10s \
            --log-file="$LOG_FILE" \
            --log-level INFO \
            $DRY \
            $EXTRA_ARGS

        local EXIT_CODE=$?

        if [[ "$EXIT_CODE" -eq 0 ]]; then
            echo "✅ Success: $SRC"
            return
        fi

        echo "⚠ Error (code $EXIT_CODE) → reducing TPS"

        CURRENT_TPS=$((CURRENT_TPS - 1))
        [[ "$CURRENT_TPS" -lt 1 ]] && CURRENT_TPS=1

        ATTEMPT=$((ATTEMPT + 1))
        sleep 5
    done

    echo "❌ Failed after $MAX_ATTEMPTS attempts: $SRC"
}

# -----------------------------
# Parallel execution
# -----------------------------
PIDS=()

while IFS=":" read -r SRC DEST; do
    [[ -z "$SRC" ]] && continue
    [[ -z "$DEST" ]] && continue

    run_sync "$SRC" "$DEST" &

    PIDS+=($!)

    if [[ "${#PIDS[@]}" -ge "$PARALLEL_JOBS" ]]; then
        wait -n
    fi

done < <(grep -v '^#' "$CONFIG_FILE" | grep -v '^$')

wait

echo
echo "================================"
echo "✅ ALL SYNC COMPLETE"
echo "Logs: $LOG_DIR"
echo "================================"