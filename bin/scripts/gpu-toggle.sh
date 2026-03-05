#!/bin/bash
# Hybrid GPU toggle for ASUS ROG laptops
# Usage: gpu-toggle.sh
# Requires reboot to take effect

# Check if supergfxctl is available
if ! command -v supergfxctl &> /dev/null; then
    notify-send "GPU Toggle" "supergfxctl not installed" -u critical -t 3000
    exit 1
fi

# Get current GPU mode
gpu_mode=$(supergfxctl -g 2>/dev/null)

if [[ -z $gpu_mode ]]; then
    notify-send "GPU Toggle" "Could not detect GPU mode" -u critical -t 3000
    exit 1
fi

case "$gpu_mode" in
"Integrated")
    notify-send "GPU Toggle" "Current: Integrated GPU\nClick to enable Hybrid (requires reboot)" -t 10000 -A "switch=Switch to Hybrid"
    if [[ $? -eq 0 ]]; then
        # User clicked
        sudo supergfxctl -m Hybrid
        if [[ $? -eq 0 ]]; then
            notify-send "GPU Toggle" "Switched to Hybrid mode\nPlease reboot to apply" -u critical -t 5000
        else
            notify-send "GPU Toggle" "Failed to switch mode" -u critical -t 5000
        fi
    fi
    ;;
"Hybrid")
    notify-send "GPU Toggle" "Current: Hybrid GPU\nClick to enable Integrated (requires reboot)" -t 10000 -A "switch=Switch to Integrated"
    if [[ $? -eq 0 ]]; then
        # User clicked
        sudo supergfxctl -m Integrated
        if [[ $? -eq 0 ]]; then
            notify-send "GPU Toggle" "Switched to Integrated mode\nPlease reboot to apply" -u critical -t 5000
        else
            notify-send "GPU Toggle" "Failed to switch mode\nCheck /etc/supergfxd.conf permissions" -u critical -t 5000
        fi
    fi
    ;;
*)
    notify-send "GPU Toggle" "Unknown GPU mode: $gpu_mode" -u critical -t 3000
    exit 1
    ;;
esac

echo "Current GPU mode: $gpu_mode"