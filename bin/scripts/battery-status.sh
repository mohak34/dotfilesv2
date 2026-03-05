#!/bin/bash
# Battery status for ASUS ROG laptops
# Usage: battery-status.sh

# Get battery info
BATTERY_PATH="/sys/class/power_supply/BAT0"

if [[ ! -d $BATTERY_PATH ]]; then
    notify-send "Battery Status" "No battery found" -u critical -t 3000
    exit 1
fi

# Read battery data
capacity=$(cat "$BATTERY_PATH/capacity" 2>/dev/null)
status=$(cat "$BATTERY_PATH/status" 2>/dev/null)
power_now=$(cat "$BATTERY_PATH/power_now" 2>/dev/null || echo "0")

# Format power draw
if [[ $power_now -gt 0 ]]; then
    power_watts=$(awk "BEGIN {printf \"%.1f\", $power_now / 1000000}")
    if [[ $status == "Charging" ]]; then
        power_text="+${power_watts}W charging"
    else
        power_text="-${power_watts}W discharging"
    fi
else
    power_text="AC power"
fi

# Format status text
case $status in
    "Charging") status_text="Charging" ;;
    "Full") status_text="Full" ;;
    *) status_text="Battery" ;;
esac

# Get charge limit (if available)
charge_limit=$(cat /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || echo "")
if [[ -n $charge_limit ]]; then
    limit_text="\nCharge limit: ${charge_limit}%"
else
    limit_text=""
fi

# Show notification
notify-send "Battery Status" "${status_text}: ${capacity}% - ${power_text}${limit_text}" -t 3000

echo "Battery: ${capacity}%, ${status}, ${power_text}"