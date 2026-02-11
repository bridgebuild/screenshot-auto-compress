#!/bin/bash
# screenshot-folder-watchdog.sh
# Checks if ~/Desktop/Screenshots/ exists. If not, recreates it via Finder
# (since launchd agents can't create folders on Desktop directly due to TCC)
# and re-attaches the Folder Action for auto-compression.
# Runs every 5 seconds via launchd.

SCREENSHOTS_DIR="$HOME/Desktop/Screenshots"

if [[ ! -d "$SCREENSHOTS_DIR" ]]; then
    # Use Finder (osascript) to create the folder - bypasses TCC restrictions
    osascript -e "
        tell application \"Finder\"
            if not (exists folder \"Screenshots\" of desktop) then
                make new folder at desktop with properties {name:\"Screenshots\"}
            end if
        end tell
    " 2>/dev/null

    # Wait for Finder to finish
    sleep 1

    # Re-attach the Folder Action
    osascript -e "
        tell application \"System Events\"
            try
                delete folder action \"Screenshots\"
            end try
            set fa to make new folder action with properties {name:\"Screenshots\", path:\"$SCREENSHOTS_DIR\"}
            tell fa
                make new script with properties {name:\"Compress Screenshots.scpt\", POSIX path:\"$HOME/Library/Scripts/Folder Action Scripts/Compress Screenshots.scpt\"}
            end tell
        end tell
    " 2>/dev/null

    echo "$(date '+%Y-%m-%d %H:%M:%S') Recreated Screenshots folder + Folder Action" >> "$HOME/.local/logs/screenshot-compress.log"
fi
