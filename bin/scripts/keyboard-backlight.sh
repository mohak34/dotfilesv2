#!/bin/bash
# Keyboard backlight control for ASUS ROG laptops
# Usage: keyboard-backlight.sh [up|down|cycle]

DIRECTION="${1:-cycle}"

# Find keyboard backlight device
device=""
for candidate in /sys/class/leds/*kbd_backlight*; do
    if [[ -e $candidate ]]; then
        device="$(basename "$candidate")"
        break
    fi
done

if [[ -z $device ]]; then
    notify-send "Keyboard Backlight" "No keyboard backlight device found" -u critical -t 3000
    exit 1
fi

# Get current and max brightness
max_brightness="$(brightnessctl -d "$device" max)"
current_brightness="$(brightnessctl -d "$device" get)"

# Calculate new brightness
if [[ $DIRECTION == "cycle" ]]; then
    new_brightness=$(( (current_brightness + 1) % (max_brightness + 1) ))
elif [[ $DIRECTION == "up" ]]; then
    new_brightness=$((current_brightness + 1))
    (( new_brightness > max_brightness )) && new_brightness=$max_brightness
else
    new_brightness=$((current_brightness - 1))
    (( new_brightness < 0 )) && new_brightness=0
fi

# Set the new brightness
brightnessctl -d "$device" set "$new_brightness" >/dev/null

# Show notification
percent=$((new_brightness * 100 / max_brightness))
notify-send "Keyboard Backlight" "Brightness: ${percent}%" -t 1500

echo "Keyboard backlight set to ${percent}%"