#!/bin/bash

echo "Interactive Folder Builder"

FOLDER_FILE="config/folders.conf"

echo "Add folder mapping:"
read -p "Source folder: " SRC
read -p "Cloud destination: " DEST

echo "$SRC -> $DEST" >> "$FOLDER_FILE"

echo "Added."