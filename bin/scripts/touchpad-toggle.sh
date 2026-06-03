#!/bin/bash
DEVICE="asue120a:00-04f3:319b-touchpad"
STATE_FILE="/tmp/touchpad-state"

if [ -f "$STATE_FILE" ] && [ "$(cat $STATE_FILE)" = "disabled" ]; then
    hyprctl eval "hl.device({name = \"$DEVICE\", enabled = true})"
    echo "enabled" > "$STATE_FILE"
    notify-send -t 2000 "Touchpad" "Enabled"
else
    hyprctl eval "hl.device({name = \"$DEVICE\", enabled = false})"
    echo "disabled" > "$STATE_FILE"
    notify-send -t 2000 "Touchpad" "Disabled"
fi
