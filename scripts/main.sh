#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "dev")
echo "SmartCloudSyncWithRclone Version: $VERSION"

ACTION=""
MODE="live"

# Parse arguments properly
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
        *)
            shift
            ;;
    esac
done

if [ -z "$ACTION" ]; then
    echo "Usage:"
    echo " smartcloud setup"
    echo " smartcloud sync --mode live|backup|both"
    echo " smartcloud release"
    exit 1
fi

echo "PROJECT ROOT = $PROJECT_ROOT"

case "$ACTION" in

setup)
    bash "$PROJECT_ROOT/scripts/remote_setup.sh"
    bash "$PROJECT_ROOT/tools/interactive_builder.sh"
    ;;

sync)
    bash "$PROJECT_ROOT/scripts/validator.sh"

    export SYNC_MODE="$MODE"

    bash "$PROJECT_ROOT/scripts/sync_engine.sh"
    ;;

release)
    bash "$PROJECT_ROOT/tools/release_builder.sh"
    ;;

esac
