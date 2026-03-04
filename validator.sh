#!/bin/bash

echo "Validating project..."

if [ ! -f config/config.sh ]; then
    echo "Missing config/config.sh"
    exit 1
fi

if [ ! -f config/folders.conf ]; then
    echo "Missing config/folders.conf"
    exit 1
fi

echo "Validation OK."