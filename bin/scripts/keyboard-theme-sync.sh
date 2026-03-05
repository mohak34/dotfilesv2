#!/bin/bash
# Sync ASUS ROG keyboard RGB with matugen wallpaper colors
# Usage: keyboard-theme-sync.sh

# Check if asusctl is available
if ! command -v asusctl &> /dev/null; then
    notify-send "Keyboard Theme Sync" "asusctl not installed" -u critical -t 3000
    exit 1
fi

# Read matugen colors
MATUGEN_COLORS="$HOME/.config/matugen/colors.json"

if [[ ! -f $MATUGEN_COLORS ]]; then
    notify-send "Keyboard Theme Sync" "matugen colors.json not found" -u critical -t 3000
    exit 1
fi

# Extract primary color from matugen
# Try different possible structures for compatibility
PRIMARY_COLOR=$(jq -r '.colors.primary.dark // .colors.primary.default // empty' "$MATUGEN_COLORS" 2>/dev/null)

if [[ -z $PRIMARY_COLOR || $PRIMARY_COLOR == "null" ]]; then
    # Fallback: try schemes.dark.primary (omarchy-style)
    PRIMARY_COLOR=$(jq -r '.schemes.dark.primary // empty' "$MATUGEN_COLORS" 2>/dev/null)
fi

if [[ -z $PRIMARY_COLOR || $PRIMARY_COLOR == "null" ]]; then
    # Final fallback: get first color from colors object
    PRIMARY_COLOR=$(jq -r '.colors | to_entries | .[0].value' "$MATUGEN_COLORS" 2>/dev/null | head -1)
fi

if [[ -z $PRIMARY_COLOR || $PRIMARY_COLOR == "null" ]]; then
    notify-send "Keyboard Theme Sync" "Could not extract color from matugen" -u critical -t 3000
    exit 1
fi

# Remove # if present
PRIMARY_COLOR="${PRIMARY_COLOR#\#}"

# Set keyboard LED color using asusctl
asusctl aura effect static -c "$PRIMARY_COLOR" 2>/dev/null

if [[ $? -eq 0 ]]; then
    notify-send "Keyboard Theme Sync" "Color set to #${PRIMARY_COLOR}" -t 2000
    echo "Keyboard color synced: #${PRIMARY_COLOR}"
else
    notify-send "Keyboard Theme Sync" "Failed to set keyboard color" -u critical -t 3000
    exit 1
fi