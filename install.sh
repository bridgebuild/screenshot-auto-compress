#!/bin/bash
# install.sh - Screenshot Auto-Compress installer for macOS
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USERNAME="$(whoami)"
PLIST_LABEL="com.${USERNAME}.screenshot-watchdog"

echo "=== Screenshot Auto-Compress Installer ==="
echo ""

# 1. Install Homebrew dependencies
echo "[1/7] Installing dependencies (pngquant + oxipng)..."
if ! command -v pngquant &>/dev/null || ! command -v oxipng &>/dev/null; then
    brew install pngquant oxipng
else
    echo "  Already installed."
fi

# 2. Create directories
echo "[2/7] Creating directories..."
mkdir -p ~/.local/bin ~/.local/logs
mkdir -p ~/Library/Scripts/Folder\ Action\ Scripts

# 3. Install compression script
echo "[3/7] Installing compression script..."
cp "$SCRIPT_DIR/scripts/screenshot-compress-single.sh" ~/.local/bin/
chmod +x ~/.local/bin/screenshot-compress-single.sh

# 4. Install watchdog script
echo "[4/7] Installing watchdog script..."
cp "$SCRIPT_DIR/scripts/screenshot-folder-watchdog.sh" ~/.local/bin/
chmod +x ~/.local/bin/screenshot-folder-watchdog.sh

# 5. Compile and install Folder Action
echo "[5/7] Compiling Folder Action AppleScript..."
osacompile -o ~/Library/Scripts/Folder\ Action\ Scripts/Compress\ Screenshots.scpt \
    "$SCRIPT_DIR/scripts/compress-screenshots.applescript"

# 6. Install and load launchd plist
echo "[6/7] Installing watchdog launchd agent..."
sed "s|PLACEHOLDER_HOME|$HOME|g; s|com.screenshot-watchdog|${PLIST_LABEL}|g" \
    "$SCRIPT_DIR/scripts/com.screenshot-watchdog.plist" \
    > ~/Library/LaunchAgents/${PLIST_LABEL}.plist
launchctl unload ~/Library/LaunchAgents/${PLIST_LABEL}.plist 2>/dev/null || true
launchctl load ~/Library/LaunchAgents/${PLIST_LABEL}.plist

# 7. Configure macOS
echo "[7/7] Configuring macOS..."

# Set file-save location to ~/Desktop/Screenshots
defaults write com.apple.screencapture location ~/Desktop/Screenshots

# Create Screenshots folder via Finder (avoids TCC issues)
osascript -e '
tell application "Finder"
    if not (exists folder "Screenshots" of desktop) then
        make new folder at desktop with properties {name:"Screenshots"}
    end if
end tell
' 2>/dev/null

# Attach Folder Action
osascript -e "
tell application \"System Events\"
    try
        delete folder action \"Screenshots\"
    end try
    set fa to make new folder action with properties {name:\"Screenshots\", path:\"$HOME/Desktop/Screenshots\"}
    tell fa
        make new script with properties {name:\"Compress Screenshots.scpt\", POSIX path:\"$HOME/Library/Scripts/Folder Action Scripts/Compress Screenshots.scpt\"}
    end tell
    set folder actions enabled to true
end tell
" 2>/dev/null

killall SystemUIServer 2>/dev/null || true

echo ""
echo "=== Done! ==="
echo ""
echo "How it works:"
echo "  Take a screenshot -> Saved to ~/Desktop/Screenshots/"
echo "  Auto-compressed with pngquant + oxipng (~50-70% smaller)"
echo "  Compressed image automatically copied to clipboard for pasting"
echo ""
echo "Logs: ~/.local/logs/screenshot-compress.log"
