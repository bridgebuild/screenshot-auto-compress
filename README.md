# Screenshot Auto-Compress

Auto-compresses macOS screenshots using **pngquant** (lossy) + **oxipng** (lossless). Saves ~50-70% file size with no visible quality loss. Compressed screenshots are automatically copied to your clipboard for easy pasting.

## Quick Install

```bash
git clone https://github.com/bridgebuild/screenshot-auto-compress.git
cd screenshot-auto-compress
chmod +x install.sh && ./install.sh
```

## How It Works

1. Take a screenshot (`Cmd+Shift+3`, `Cmd+Shift+4`, etc.)
2. macOS saves it to `~/Desktop/Screenshots/`
3. A **macOS Folder Action** triggers automatically
4. The compression script runs pngquant + oxipng (~50-70% smaller)
5. Original is replaced with a compressed version named `(Comp).png`
6. Compressed image is **copied to your clipboard** — ready to paste
7. A **watchdog** (every 5s) recreates the folder + Folder Action if deleted

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
# Screenshots save to ~/Desktop/Screenshots/
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
defaults write com.apple.screencapture location ~/Desktop
killall SystemUIServer
```

## License

MIT
