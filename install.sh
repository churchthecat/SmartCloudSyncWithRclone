#!/usr/bin/env bash

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

sudo ln -sf "$PROJECT_ROOT/scripts/main.sh" /usr/local/bin/smartcloud

echo "SmartCloud installed"
echo "Command available: smartcloud"
