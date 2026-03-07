#!/usr/bin/env bash
set -e

CONFIG_FILE="$PWD/config/config.sh"
FOLDERS_FILE="$PWD/config/folders.conf"
TMP_FILE="$FOLDERS_FILE.tmp"

echo "============================"
echo " SmartCloud Configuration CLI"
echo "============================"

# --------------------------------------------------
# Clean temporary file first (atomic rewrite)
# --------------------------------------------------
> "$TMP_FILE"

# --------------------------------------------------
# Step 1 – Remote Configuration
# --------------------------------------------------
echo
echo "Step 1: Remote Setup"

read -rp "Enter your rclone remote name: " REMOTE_NAME

if ! rclone listremotes | grep -q "^${REMOTE_NAME}:$"; then
    echo "⚠ Remote not found. Run 'rclone config' if needed."
fi

read -rp "Enter remote root path (default: backup-root): " REMOTE_BASE_PATH
REMOTE_BASE_PATH=${REMOTE_BASE_PATH:-backup-root}

# --------------------------------------------------
# Step 2 – Bandwidth
# --------------------------------------------------
echo
echo "Step 2: Bandwidth Settings"

read -rp "Fast Percent [80]: " FAST_PERCENT
FAST_PERCENT=${FAST_PERCENT:-80}

read -rp "Normal Percent [50]: " NORMAL_PERCENT
NORMAL_PERCENT=${NORMAL_PERCENT:-50}

read -rp "Slow Limit Mbit [2]: " SLOW_LIMIT_MBIT
SLOW_LIMIT_MBIT=${SLOW_LIMIT_MBIT:-2}

LOGFILE="$HOME/smartcloud.log"

# --------------------------------------------------
# Write config safely (overwrite fully)
# --------------------------------------------------
cat > "$CONFIG_FILE" <<EOF
REMOTE_NAME="$REMOTE_NAME"
REMOTE_BASE_PATH="$REMOTE_BASE_PATH"

FAST_PERCENT=$FAST_PERCENT
NORMAL_PERCENT=$NORMAL_PERCENT
SLOW_LIMIT_MBIT=$SLOW_LIMIT_MBIT

LOGFILE="$LOGFILE"
EOF

echo "✔ config.sh updated"

# --------------------------------------------------
# Step 3 – Folder Mappings
# --------------------------------------------------
echo
echo "Step 3: Folder Mappings"
echo "Add folders (leave empty to finish)"

while true; do
    read -rp "Local folder path: " LOCAL
    [[ -z "$LOCAL" ]] && break

    read -rp "Remote folder path relative to $REMOTE_BASE_PATH: " REMOTE

    echo "$LOCAL -> $REMOTE" >> "$TMP_FILE"
    echo "✔ Added: $LOCAL -> $REMOTE"
done

# --------------------------------------------------
# Step 4 – Global Exclusions
# --------------------------------------------------
echo
echo "Step 4: Global Exclusions"
echo "Add exclusions (leave empty to finish)"

echo "" >> "$TMP_FILE"
echo "EXCLUDE:" >> "$TMP_FILE"

while true; do
    read -rp "Exclude pattern: " PATTERN
    [[ -z "$PATTERN" ]] && break

    echo "$PATTERN" >> "$TMP_FILE"
    echo "✔ Exclusion added"
done

# --------------------------------------------------
# Replace folders.conf atomically
# --------------------------------------------------
mv "$TMP_FILE" "$FOLDERS_FILE"

# --------------------------------------------------
# Step 5 – Timers
# --------------------------------------------------
echo
echo "Step 5: Enable systemd timers? (y/N)"
read -r ENABLE_TIMERS

if [[ "$ENABLE_TIMERS" =~ ^[Yy]$ ]]; then
    bash "$PWD/install.sh" --enable-timers
fi

echo
echo "✅ Configuration complete!"
echo "Run:"
echo "  smartcloud sync --mode live"
echo "  smartcloud sync --mode both"