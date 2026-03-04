#!/bin/bash

# ==========================================================
# SmartCloudSyncWithRclone - Main Entry
# Portable | Symlink Safe | Install Safe
# ==========================================================

# ===== Resolve Script Location (Symlink Safe) =====
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done

SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"   # ← go one level up to project root

# ===== Version =====
VERSION=$(git -C "$BASE_DIR" describe --tags --abbrev=0 2>/dev/null || echo "dev")

echo "SmartCloudSyncWithRclone Version: $VERSION"
echo "PROJECT ROOT = $BASE_DIR"

# ===== Argument Parsing =====
ACTION=""
MODE="live"

while [[ $# -gt 0 ]]; do
    case "$1" in
        setup|sync|release)
            ACTION="$1"
            shift
            ;;
        --mode)
            MODE="$2"
            shift 2
            ;;
        --live)
            MODE="live"
            shift
            ;;
        --backup)
            MODE="backup"
            shift
            ;;
        --both)
            MODE="both"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# ===== Action Handler =====
case "$ACTION" in

setup)
    bash "$BASE_DIR/remote_setup.sh"
    bash "$BASE_DIR/interactive_builder.sh"
    ;;

sync)
    export SYNC_MODE="$MODE"

    bash "$BASE_DIR/validator.sh"
    bash "$BASE_DIR/sync_engine.sh"
    ;;

release)
    bash "$BASE_DIR/release_builder.sh"
    ;;

*)
    echo "Unknown command"
    ;;
esac
