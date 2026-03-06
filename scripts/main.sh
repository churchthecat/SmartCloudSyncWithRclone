#!/bin/bash

# Resolve project root safely
SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

VERSION=$(git -C "$PROJECT_ROOT" describe --tags --abbrev=0 2>/dev/null || echo "dev")
echo "SmartCloudSyncWithRclone Version: $VERSION"

ACTION=""
MODE="live"

while [[ $# -gt 0 ]]; do
    case "$1" in
        setup|sync|release|status)
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
    echo " smartcloud status"
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

    bash "$PROJECT_ROOT/sync_engine.sh"
    ;;

status)

    echo
    echo "SmartCloud Status"
    echo "-----------------"

    LAST_SYNC=$(journalctl --user -u smartcloud-sync.service -n 1 --no-pager 2>/dev/null | awk '{print $1,$2,$3}')

    TIMER_STATE=$(systemctl --user is-active smartcloud-sync.timer 2>/dev/null)

    NEXT_SYNC=$(systemctl --user list-timers smartcloud-sync.timer --no-pager 2>/dev/null | awk 'NR==2 {print $1,$2}')

    echo "Timer Active:   $TIMER_STATE"
    echo "Next Sync:      $NEXT_SYNC"
    echo "Last Sync Log:"
    echo

    journalctl --user -u smartcloud-sync.service -n 10 --no-pager 2>/dev/null

    ;;

release)

    bash "$PROJECT_ROOT/tools/release_builder.sh"
    ;;

esac