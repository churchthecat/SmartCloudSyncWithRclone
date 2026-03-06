#!/usr/bin/env bash

set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/config/config.sh"

FOLDERS_CONF="$BASE_DIR/config/folders.conf"

echo "Starting sync engine..."

TMP_RULES=$(mktemp)
TMP_EXCLUDES=$(mktemp)

# Extract sync rules safely
grep -- "->" "$FOLDERS_CONF" | sed 's/^[ \t]*//' > "$TMP_RULES"

# Extract exclusions
awk '/EXCLUDE:/ {flag=1; next} flag' "$FOLDERS_CONF" > "$TMP_EXCLUDES"

echo "Loaded sync rules:"
cat "$TMP_RULES"
echo

while read -r line; do

    LOCAL=$(echo "$line" | cut -d'-' -f1 | sed 's/[ >]*$//')
    REMOTE=$(echo "$line" | cut -d'>' -f2 | sed 's/^ *//')

    echo
    echo "Syncing $LOCAL -> $REMOTE"

    rclone sync \
        "$LOCAL" \
        "$REMOTE:$REMOTE" \
        --progress \
        --transfers=4 \
        --checkers=8 \
        --exclude-from="$TMP_EXCLUDES" \
        --log-file="$LOGFILE" \
        --log-level INFO

done < "$TMP_RULES"

rm "$TMP_RULES"
rm "$TMP_EXCLUDES"

echo
echo "Sync complete."