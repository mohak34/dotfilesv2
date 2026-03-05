#!/bin/bash
# Screenshot script with smart workflow
# Usage: screenshot.sh [smart|region|window|fullscreen|monitor]
# Editor only opens when notification is clicked

# Configuration
OUTPUT_DIR="${SCREENSHOT_DIR:-${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots}"
EDITOR="${SCREENSHOT_EDITOR:-satty}"

# Create directory if needed
[[ ! -d $OUTPUT_DIR ]] && mkdir -p "$OUTPUT_DIR"

# Kill existing slurp to toggle off
pkill slurp && exit 0

MODE="${1:-smart}"

# JQ filter for monitor geometry (handles portrait/rotated displays)
JQ_MONITOR_GEO='
    def format_geo:
        .x as $x | .y as $y |
        (.width / .scale | floor) as $w |
        (.height / .scale | floor) as $h |
        .transform as $t |
        if $t == 1 or $t == 3 then
            "\($x),\($y) \($h)x\($w)"
        else
            "\($x),\($y) \($w)x\($h)"
        end;
'

# Get rectangles for current workspace
get_rectangles() {
    local active_workspace=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')
    hyprctl monitors -j | jq -r --arg ws "$active_workspace" "${JQ_MONITOR_GEO} .[] | select(.activeWorkspace.id == (\$ws | tonumber)) | format_geo"
    hyprctl clients -j | jq -r --arg ws "$active_workspace" '.[] | select(.workspace.id == ($ws | tonumber)) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
}

open_editor() {
    local filepath="$1"
    if [[ $EDITOR == "satty" ]]; then
        satty --filename "$filepath" \
            --output-filename "$filepath" \
            --actions-on-enter save-to-clipboard \
            --save-after-copy \
            --copy-command 'wl-copy'
    else
        $EDITOR "$filepath"
    fi
}

# Select based on mode
case "$MODE" in
    region)
        hyprpicker -r -z >/dev/null 2>&1 & PID=$!
        sleep .1
        SELECTION=$(slurp 2>/dev/null)
        kill $PID 2>/dev/null
        ;;
    window)
        hyprpicker -r -z >/dev/null 2>&1 & PID=$!
        sleep .1
        SELECTION=$(get_rectangles | slurp -r 2>/dev/null)
        kill $PID 2>/dev/null
        ;;
    fullscreen)
        SELECTION=$(hyprctl monitors -j | jq -r "${JQ_MONITOR_GEO} .[] | select(.focused == true) | format_geo")
        ;;
    monitor)
        ACTIVE_MONITOR=$(hyprctl activeworkspace -j | jq -r ".monitor")
        SELECTION=$(hyprctl monitors -j | jq -r --arg mon "$ACTIVE_MONITOR" "${JQ_MONITOR_GEO} .[] | select(.name == \$mon) | format_geo")
        ;;
    smart|*)
        RECTS=$(get_rectangles)
        hyprpicker -r -z >/dev/null 2>&1 & PID=$!
        sleep .1
        SELECTION=$(echo "$RECTS" | slurp 2>/dev/null)
        kill $PID 2>/dev/null

        # Smart click detection
        if [[ $SELECTION =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]]; then
            if ((${BASH_REMATCH[3]} * ${BASH_REMATCH[4]} < 20)); then
                click_x="${BASH_REMATCH[1]}"
                click_y="${BASH_REMATCH[2]}"
                while IFS= read -r rect; do
                    if [[ $rect =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+) ]]; then
                        rect_x="${BASH_REMATCH[1]}"
                        rect_y="${BASH_REMATCH[2]}"
                        rect_width="${BASH_REMATCH[3]}"
                        rect_height="${BASH_REMATCH[4]}"
                        if ((click_x >= rect_x && click_x < rect_x + rect_width && click_y >= rect_y && click_y < rect_y + rect_height)); then
                            SELECTION="${rect_x},${rect_y} ${rect_width}x${rect_height}"
                            break
                        fi
                    fi
                done <<<"$RECTS"
            fi
        fi
        ;;
esac

[[ -z $SELECTION ]] && exit 0

# Take screenshot
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="screenshot_${MODE}_${TIMESTAMP}.png"
FILEPATH="$OUTPUT_DIR/$FILENAME"

grim -g "$SELECTION" "$FILEPATH" || exit 1
wl-copy <"$FILEPATH"

# Notification with edit action
(
    ACTION=$(notify-send "Screenshot saved" "$FILENAME\nClick to edit" -t 10000 -i "$FILEPATH" -A "edit=Edit")
    [[ $ACTION == "edit" ]] && open_editor "$FILEPATH"
) &

echo "Screenshot saved: $FILEPATH"