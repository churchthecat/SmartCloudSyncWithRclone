#!/bin/bash

UPLOAD=$1

if [ -z "$UPLOAD" ]; then
    UPLOAD=10
fi

FAST_PERCENT=$(grep FAST_PERCENT config/config.sh | cut -d '=' -f2)
NORMAL_PERCENT=$(grep NORMAL_PERCENT config/config.sh | cut -d '=' -f2)
SLOW_LIMIT=$(grep SLOW_LIMIT_MBIT config/config.sh | cut -d '=' -f2)

if (( $(echo "$UPLOAD > 50" | bc -l) )); then
    LIMIT=$(echo "$UPLOAD * $FAST_PERCENT / 100" | bc)

elif (( $(echo "$UPLOAD > 10" | bc -l) )); then
    LIMIT=$(echo "$UPLOAD * $NORMAL_PERCENT / 100" | bc)

else
    LIMIT=$SLOW_LIMIT
fi

# Prevent empty result
if [ -z "$LIMIT" ]; then
    LIMIT=$SLOW_LIMIT
fi

echo "${LIMIT}M"
