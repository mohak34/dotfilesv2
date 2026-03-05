#!/bin/bash
# Platform profile toggle for ASUS ROG laptops
# Cycles: quiet → balanced → performance
# Usage: platform-profile.sh

# Check available profiles
PROFILES=(quiet balanced performance)
CURRENT=$(cat /sys/firmware/acpi/platform_profile 2>/dev/null)

if [[ -z $CURRENT ]]; then
    notify-send "Platform Profile" "Could not read current profile" -u critical -t 3000
    exit 1
fi

# Find current index
CURRENT_IDX=0
for i in "${!PROFILES[@]}"; do
    if [[ "${PROFILES[$i]}" == "$CURRENT" ]]; then
        CURRENT_IDX=$i
        break
    fi
done

# Get next profile
NEXT_IDX=$(( (CURRENT_IDX + 1) % ${#PROFILES[@]} ))
NEXT_PROFILE="${PROFILES[$NEXT_IDX]}"

# Set the new profile
echo "$NEXT_PROFILE" | sudo tee /sys/firmware/acpi/platform_profile >/dev/null

if [[ $? -eq 0 ]]; then
    # Show notification
    case $NEXT_PROFILE in
        "quiet")
            DESC="Quiet mode - fans off, battery save"
            ;;
        "balanced")
            DESC="Balanced mode - normal performance"
            ;;
        "performance")
            DESC="Performance mode - max power"
            ;;
    esac
    
    notify-send "Platform Profile" "${NEXT_PROFILE}\n${DESC}" -t 3000
    echo "Platform profile set to: $NEXT_PROFILE"
else
    notify-send "Platform Profile" "Failed to set profile" -u critical -t 3000
    exit 1
fi