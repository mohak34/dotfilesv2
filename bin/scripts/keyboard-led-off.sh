#!/bin/bash
# Turn off keyboard LED completely

if ! command -v asusctl &> /dev/null; then
    notify-send "Keyboard LED" "asusctl not installed" -u critical -t 3000
    exit 1
fi

asusctl leds set off

if [[ $? -eq 0 ]]; then
    notify-send "Keyboard LED" "Turned OFF" -t 1500
else
    notify-send "Keyboard LED" "Failed to turn off" -u critical -t 3000
fi