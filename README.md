# Screenshot Auto-Compress

Auto-compresses macOS screenshots using **pngquant** (lossy) + **oxipng** (lossless). Saves ~50-70% file size with no visible quality loss.

By default, screenshots go straight to your **clipboard** (no files saved). When you need a file, use `Cmd+Shift+5` to save to the Screenshots folder where auto-compression kicks in.

## Quick Install

```bash
git clone https://github.com/sergioduarte/screenshot-auto-compress.git
cd screenshot-auto-compress
chmod +x install.sh && ./install.sh
```

## How It Works

| Shortcut | Behavior |
|----------|----------|
| `Cmd+Shift+3` | Full screen -> clipboard (no file) |
| `Cmd+Shift+4` | Selection -> clipboard (no file) |
| `Cmd+Shift+5` | Screenshot toolbar -> choose "Save to Screenshots" for auto-compressed file |

When saving to file:

1. macOS saves the screenshot to `~/Desktop/Screenshots/`
2. A **macOS Folder Action** triggers on new files
3. The compression script runs pngquant + oxipng
4. Original is replaced with a compressed version named `(Comp).png`
5. A **watchdog** (every 5s) recreates the folder + Folder Action if deleted

## Files Installed

| Location | Purpose |
|----------|---------|
| `~/.local/bin/screenshot-compress-single.sh` | Compression script |
| `~/.local/bin/screenshot-folder-watchdog.sh` | Folder recreation watchdog |
| `~/Library/Scripts/Folder Action Scripts/Compress Screenshots.scpt` | macOS Folder Action trigger |
| `~/Library/LaunchAgents/com.<user>.screenshot-watchdog.plist` | Watchdog launchd agent |
| `~/.local/logs/screenshot-compress.log` | Compression log |

## macOS Settings Changed

```bash
# Screenshots default to clipboard
defaults write com.apple.screencapture target clipboard

# File saves go to ~/Desktop/Screenshots/
defaults write com.apple.screencapture location ~/Desktop/Screenshots
```

## Dependencies

- [pngquant](https://pngquant.org/) - lossy PNG compression (visually identical, big savings)
- [oxipng](https://github.com/shssoichern/oxipng) - lossless PNG optimization
- Homebrew (for installing the above)

## Key Design Decisions

- **Folder Actions** over launchd+fswatch because macOS TCC blocks launchd from accessing Desktop files
- **Compression in /tmp** avoids Desktop permission edge cases
- **Finder (osascript)** for folder creation since launchd can't create Desktop folders
- **5-second watchdog** ensures the Screenshots folder always exists

## Uninstall

```bash
chmod +x uninstall.sh && ./uninstall.sh
```

Or manually:

```bash
# Stop and remove watchdog
launchctl unload ~/Library/LaunchAgents/com.$(whoami).screenshot-watchdog.plist
rm ~/Library/LaunchAgents/com.$(whoami).screenshot-watchdog.plist

# Remove scripts
rm ~/.local/bin/screenshot-compress-single.sh
rm ~/.local/bin/screenshot-folder-watchdog.sh
rm ~/Library/Scripts/Folder\ Action\ Scripts/Compress\ Screenshots.scpt

# Remove Folder Action
osascript -e 'tell application "System Events" to delete folder action "Screenshots"'

# Reset macOS defaults
defaults delete com.apple.screencapture target
defaults write com.apple.screencapture location ~/Desktop
killall SystemUIServer
```

## License

MIT
