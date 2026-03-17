#!/usr/bin/env bash

echo "🔍 Validating configuration..."

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$PROJECT_ROOT/config"

FAIL=0

# Required files
REQUIRED_FILES=(
    "$CONFIG_DIR/config.sh"
    "$CONFIG_DIR/folders.conf"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "❌ Missing required file: $file"
        FAIL=1
    fi
done

# Validate folders.conf format
if [[ -f "$CONFIG_DIR/folders.conf" ]]; then
    while IFS=":" read -r SRC DEST; do
        [[ -z "$SRC" || -z "$DEST" ]] && continue

        if [[ "$SRC" == *" "* ]]; then
            echo "⚠ Warning: Source contains spaces: $SRC"
        fi

    done < <(grep -v '^#' "$CONFIG_DIR/folders.conf" | grep -v '^$')
fi

# Prevent dangerous root sync
if grep -qE '^/:' "$CONFIG_DIR/folders.conf" 2>/dev/null; then
    echo "❌ Dangerous config: attempting to sync root (/)"
    FAIL=1
fi

if [[ $FAIL -eq 1 ]]; then
    echo "🚫 Validation failed"
    exit 1
fi

echo "✅ Configuration OK"
exit 0
