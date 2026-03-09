#!/usr/bin/env bash

if [[ "$1" == "limit" ]]; then
    export RCLONE_BWLIMIT="5M"
    echo "Bandwidth limited to 5MB/s"
elif [[ "$1" == "unlimited" ]]; then
    unset RCLONE_BWLIMIT
    echo "Bandwidth unlimited"
else
    echo "Usage:"
    echo "smartcloud-bandwidth limit"
    echo "smartcloud-bandwidth unlimited"
fi
