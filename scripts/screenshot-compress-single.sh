#!/bin/bash
# screenshot-compress-single.sh
# Compresses a single PNG screenshot using pngquant (lossy) + oxipng (lossless).
# Called by the macOS Folder Action "Compress Screenshots.scpt".
# Original is replaced with a compressed version renamed to "(Comp).png".

set -euo pipefail

LOG="$HOME/.local/logs/screenshot-compress.log"
PNGQUANT="/usr/local/bin/pngquant"
OXIPNG="/usr/local/bin/oxipng"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG"; }

file="$1"

# Only process PNG files
[[ "$file" == *.png ]] || exit 0

# Skip already-compressed files
[[ "$file" == *"(Comp)"* ]] && exit 0

# Wait for file to finish writing (macOS may still be saving)
sleep 1

# Bail if file disappeared
[[ -f "$file" ]] || exit 0

original_size=$(stat -f%z "$file")
basename_no_ext="${file%.png}"
compressed_name="${basename_no_ext} (Comp).png"
tmp="/tmp/sc_$(date +%s%N).png"

log "START  $file ($original_size bytes)"

# Copy to /tmp for processing (avoids Desktop permission edge cases)
cp "$file" "$tmp"

# Step 1: pngquant (lossy, visually identical)
if "$PNGQUANT" --quality=70-90 --speed 1 --force --output "$tmp" -- "$tmp" 2>>"$LOG"; then
    log "  pngquant OK"
else
    log "  pngquant skipped (already optimized or error)"
fi

# Step 2: oxipng (lossless optimization)
if "$OXIPNG" -o 4 --strip safe "$tmp" 2>>"$LOG"; then
    log "  oxipng OK"
else
    log "  oxipng skipped"
fi

compressed_size=$(stat -f%z "$tmp")
savings=$(( (original_size - compressed_size) * 100 / original_size ))

# Replace original with compressed version
mv "$tmp" "$compressed_name"
rm -f "$file"

# Copy compressed screenshot to clipboard
osascript -e "set the clipboard to (read (POSIX file \"$compressed_name\") as «class PNGf»)" 2>>"$LOG" && log "  Copied to clipboard" || log "  Clipboard copy failed"

log "DONE   $compressed_name ($compressed_size bytes, ${savings}% smaller)"
