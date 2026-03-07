#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$BASE_DIR/config/config.sh"
FOLDERS_CONF="$BASE_DIR/config/folders.conf"

# --------------------------------------------------
# Load config safely
# --------------------------------------------------
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Missing config/config.sh"
    exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

# Validate required variables
if [[ -z "${REMOTE_NAME:-}" ]]; then
    echo "❌ REMOTE_NAME is not defined in config/config.sh"
    exit 1
fi

if [[ -z "${LOGFILE:-}" ]]; then
    LOGFILE="$HOME/smartcloud.log"
fi

TMP_EXCLUDES="$(mktemp)"

echo "Starting sync engine..."

# --------------------------------------------------
# Extract exclusions
# --------------------------------------------------
awk '/EXCLUDE:/ {flag=1; next} flag' "$FOLDERS_CONF" > "$TMP_EXCLUDES"

# --------------------------------------------------
# Process folder rules
# --------------------------------------------------
grep -E '^[[:space:]]*[^#].*->' "$FOLDERS_CONF" | while read -r LINE
do
    LOCAL="$(echo "$LINE" | cut -d'-' -f1 | xargs)"
    REMOTE="$(echo "$LINE" | cut -d'>' -f2 | xargs)"

    [[ -z "$LOCAL" || -z "$REMOTE" ]] && continue
    [[ ! -d "$LOCAL" ]] && { echo "⚠ Skipping missing folder: $LOCAL"; continue; }

    echo "Syncing $LOCAL -> $REMOTE"

    rclone sync \
        "$LOCAL" \
        "$REMOTE_NAME:$REMOTE" \
        --progress \
        --transfers=4 \
        --checkers=8 \
        --fast-list \
        --checksum \
        --no-update-modtime \
        --create-empty-src-dirs \
        ${BW_LIMIT:-} \
        --exclude-from="$TMP_EXCLUDES" \
        --log-file="$LOGFILE" \
        --log-level INFO

done

rm -f "$TMP_EXCLUDES"

echo "Sync complete."