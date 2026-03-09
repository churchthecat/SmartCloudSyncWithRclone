#!/usr/bin/env bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Validating SmartCloud config..."

if [[ ! -f "$PROJECT_ROOT/config/folders.conf" ]]; then
    echo "Missing folders.conf"
    exit 1
fi

if [[ ! -f "$PROJECT_ROOT/config/config.sh" ]]; then
    echo "Missing config.sh"
    exit 1
fi

echo "Config OK"
