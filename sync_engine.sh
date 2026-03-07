#!/usr/bin/env bash

set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$BASE_DIR/config/config.sh"

FOLDERS_CONF="$BASE_DIR/config/folders.conf"

TMP_RULES=$(mktemp)
TMP_EXCLUDES=$(mktemp)

echo "Starting sync engine..."

# ---- Extract only valid mappings ----
awk '
/->/ && !/^#/ && !/EXCLUDE:/ {
    print
}
' "$FOLDERS_CONF" > "$TMP_RULES"

# ---- Extract exclusions ----
awk '
/EXCLUDE:/ {flag=1; next}
flag {print}
' "$FOLDERS_CONF" > "$TMP_EXCLUDES"

# ---- Process mappings ----
while read -r LINE; do

    LOCAL=$(echo "$LINE" | awk -F"->" '{print $1}' | xargs)
    REMOTE=$(echo "$LINE" | awk -F"->" '{print $2}' | xargs)

    [[ -z "$LOCAL" ]] && continue

    if [[ -z "$REMOTE" ]]; then
        REMOTE="$REMOTE_BASE_PATH"
    fi

    echo "Syncing $LOCAL -> $REMOTE"

    rclone sync \
        "$LOCAL" \
        "$REMOTE_NAME:$REMOTE" \
        --progress \
        --transfers=4 \
        --checkers=8 \
        --ignore-existing \
        --exclude-from="$TMP_EXCLUDES" \
        --log-file="$LOGFILE" \
        --log-level INFO

done < "$TMP_RULES"

rm -f "$TMP_RULES" "$TMP_EXCLUDES"

echo "Sync complete."