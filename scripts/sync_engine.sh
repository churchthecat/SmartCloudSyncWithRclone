#!/bin/bash

source config/config.sh

LOGFILE="$LOGFILE"
MODE="${SYNC_MODE:-live}"

echo "====================" >> "$LOGFILE"
echo "SYNC START MODE: $MODE $(date)" >> "$LOGFILE"

UPLOAD=$(speedtest-cli --simple 2>/dev/null | grep Upload | awk '{print $2}')
if [ -z "$UPLOAD" ]; then
    UPLOAD=10
fi

BW_LIMIT=$(bash scripts/bandwidth.sh "$UPLOAD")

EXCLUDES=""
FOLDERS_FILE="config/folders.conf"

while read LINE; do

    if [[ $LINE == EXCLUDE:* ]]; then
        PATTERN="${LINE#EXCLUDE:}"
        EXCLUDES+="--exclude $PATTERN "

    elif [[ $LINE == */* ]]; then

        SRC=$(echo "$LINE" | cut -d ' ' -f1)
        DEST=$(echo "$LINE" | cut -d '>' -f2 | sed 's/ //g')

        #####################################
        # LIVE MODE
        #####################################
        if [[ "$MODE" == "live" || "$MODE" == "both" ]]; then

            rclone sync "$SRC" "$REMOTE:$DEST" \
                --min-size 1b \
                $EXCLUDES \
                --bwlimit "$BW_LIMIT" \
                --fast-list \
                --log-file "$LOGFILE" \
                --log-level INFO
        fi

        #####################################
        # BACKUP MODE (Versioned Copy)
        #####################################
        if [[ "$MODE" == "backup" || "$MODE" == "both" ]]; then

            BACKUP_DEST="${DEST}_backup_$(date +%Y%m%d_%H%M%S)"

            rclone copy "$SRC" "$REMOTE:$BACKUP_DEST" \
                --min-size 1b \
                --bwlimit "$BW_LIMIT" \
                --fast-list \
                --log-file "$LOGFILE" \
                --log-level INFO
        fi

    fi

done < "$FOLDERS_FILE"

echo "SYNC DONE" >> "$LOGFILE"
