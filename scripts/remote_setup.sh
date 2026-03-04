#!/bin/bash

echo "Checking rclone remotes..."

rclone listremotes

echo ""
echo "If remote not configured, run:"
echo "rclone config"
echo ""