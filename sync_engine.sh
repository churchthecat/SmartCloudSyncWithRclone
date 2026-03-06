#!/usr/bin/env bash

set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$BASE_DIR/config/config.sh"

FOLDERS_CONF="$BASE_DIR/config/folders.conf"

TMP_RULES=$(mktemp)
TMP_EXCLUDES=$(mktemp)

echo "Starting sync engine..."

grep -- "->" "$FOLDERS_CONF" | sed 's/^[ \t]*//' > "$TMP_RULES"
awk '/EXCLUDE:/ {flag=1; next} flag' "$FOLDERS_CONF" > "$TMP_EXCLUDES"

while read -r line; do

    LOCAL=$(echo "$line" | cut -d'-' -f1 | sed 's/[ >]*$//')
    REMOTE=$(echo "$line" | cut -d'>' -f2 | sed 's/^ *//')

    echo "Syncing $LOCAL -> $REMOTE"

    rclone sync \
        "$LOCAL" \
        "$REMOTE:$REMOTE" \
        --progress \
        --transfers=4 \
        --checkers=8 \
        $BW_LIMIT \
        --exclude-from="$TMP_EXCLUDES" \
        --log-file="$LOGFILE" \
        --log-level INFO

done < "$TMP_RULES"

rm -f "$TMP_RULES" "$TMP_EXCLUDES"

echo "Sync complete."