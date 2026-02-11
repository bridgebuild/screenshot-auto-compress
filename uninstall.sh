#!/bin/bash
# uninstall.sh - Screenshot Auto-Compress uninstaller for macOS
set -euo pipefail

USERNAME="$(whoami)"
PLIST_LABEL="com.${USERNAME}.screenshot-watchdog"

echo "=== Screenshot Auto-Compress Uninstaller ==="
echo ""

# Remove watchdog
echo "[1/4] Removing watchdog launchd agent..."
launchctl unload ~/Library/LaunchAgents/${PLIST_LABEL}.plist 2>/dev/null || true
rm -f ~/Library/LaunchAgents/${PLIST_LABEL}.plist

# Remove scripts
echo "[2/4] Removing scripts..."
rm -f ~/.local/bin/screenshot-compress-single.sh
rm -f ~/.local/bin/screenshot-folder-watchdog.sh
rm -f ~/Library/Scripts/Folder\ Action\ Scripts/Compress\ Screenshots.scpt

# Remove Folder Action
echo "[3/4] Removing Folder Action..."
osascript -e 'tell application "System Events" to delete folder action "Screenshots"' 2>/dev/null || true

# Reset macOS settings
echo "[4/4] Resetting screenshot settings..."
defaults write com.apple.screencapture location ~/Desktop
killall SystemUIServer 2>/dev/null || true

echo ""
echo "=== Done! ==="
echo "Screenshots will now save to ~/Desktop as default PNGs."
echo "Note: ~/Desktop/Screenshots/ folder was left in place. Delete manually if desired."
