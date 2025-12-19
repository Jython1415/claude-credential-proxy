#!/bin/bash
# Install LaunchAgent to auto-start Flask server on login

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENV_PYTHON="$PROJECT_DIR/.venv/bin/python"
SERVER_SCRIPT="$PROJECT_DIR/server/proxy_server.py"
PLIST_FILE="$HOME/Library/LaunchAgents/com.joshuashew.gitproxy.plist"

echo "Installing Git Proxy LaunchAgent..."
echo "Project directory: $PROJECT_DIR"

# Check if venv exists
if [ ! -f "$VENV_PYTHON" ]; then
    echo "Error: Virtual environment not found at $VENV_PYTHON"
    echo "Run ./scripts/setup.sh first"
    exit 1
fi

# Create LaunchAgent plist
cat > "$PLIST_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.joshuashew.gitproxy</string>

    <key>ProgramArguments</key>
    <array>
        <string>$VENV_PYTHON</string>
        <string>$SERVER_SCRIPT</string>
    </array>

    <key>WorkingDirectory</key>
    <string>$PROJECT_DIR</string>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/gitproxy.log</string>

    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/gitproxy-error.log</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>
EOF

echo "✓ Created LaunchAgent plist: $PLIST_FILE"

# Load the LaunchAgent
launchctl load "$PLIST_FILE"
echo "✓ Loaded LaunchAgent"

# Check if it's running
sleep 2
if launchctl list | grep -q "com.joshuashew.gitproxy"; then
    echo "✓ Git proxy server is running"
    echo ""
    echo "Server will now auto-start on login!"
    echo "Logs: ~/Library/Logs/gitproxy.log"
else
    echo "⚠ Warning: LaunchAgent loaded but not running"
    echo "Check logs: ~/Library/Logs/gitproxy-error.log"
fi
