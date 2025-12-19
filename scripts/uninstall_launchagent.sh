#!/bin/bash
# Uninstall Git Proxy LaunchAgent

set -e

PLIST_FILE="$HOME/Library/LaunchAgents/com.joshuashew.gitproxy.plist"

if [ ! -f "$PLIST_FILE" ]; then
    echo "LaunchAgent not installed"
    exit 0
fi

echo "Uninstalling Git Proxy LaunchAgent..."

# Unload
launchctl unload "$PLIST_FILE" 2>/dev/null || true

# Remove plist
rm "$PLIST_FILE"

echo "✓ LaunchAgent removed"
echo "Server will no longer auto-start on login"
