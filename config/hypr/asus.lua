-- asus.lua - ASUS-specific Hyprland keybinds and configuration
-- This file is loaded by hyprland.lua unconditionally.

local mainMod = "SUPER"

hl.bind("XF86Launch4", hl.dsp.exec_cmd("~/.local/bin/scripts/platform-profile.sh"))
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("~/.local/bin/scripts/keyboard-backlight.sh up"))
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("~/.local/bin/scripts/keyboard-backlight.sh down"))
hl.bind("XF86Launch3", hl.dsp.exec_cmd("asusctl aura effect --next-mode"))
hl.bind("XF86TouchpadToggle", hl.dsp.exec_cmd("~/.local/bin/scripts/touchpad-toggle.sh"), { locked = true })
hl.bind(mainMod .. " + ALT + K", hl.dsp.exec_cmd("~/.local/bin/scripts/keyboard-theme-sync.sh"))
hl.bind(mainMod .. " + ALT + SHIFT + K", hl.dsp.exec_cmd("~/.local/bin/scripts/keyboard-led-off.sh"))
hl.bind(mainMod .. " + ALT + G", hl.dsp.exec_cmd("~/.local/bin/scripts/gpu-toggle.sh"))
hl.bind(mainMod .. " + ALT + B", hl.dsp.exec_cmd("~/.local/bin/scripts/battery-status.sh"))
