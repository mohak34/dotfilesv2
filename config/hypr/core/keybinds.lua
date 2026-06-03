local mainMod = "SUPER"

-- Window/Session actions
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + F", function()
  local w = hl.get_active_window()
  if not w then return end
  local cli = tonumber(w.fullscreen_client) or 0
  if cli == 0 then
    hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 2, client = 2, action = "set" }))
  else
    hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 2, client = 2, action = "toggle" }))
  end
end)
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle" }))
hl.bind("CONTROL + ALT + W", hl.dsp.exec_cmd("~/.local/bin/scripts/waybar-toggle.sh"))
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + CONTROL + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + CONTROL + Q", hl.dsp.exec_cmd("wlogout --layout ~/.config/wlogout/layout --css ~/.config/wlogout/style.css --buttons-per-row 5 --show-binds"))

-- Application shortcuts
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("zen-browser"))
hl.bind(mainMod .. " + CONTROL + V", hl.dsp.exec_cmd("pavucontrol"))

-- Audio control
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("~/.local/bin/scripts/mic-toggle.sh"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { locked = true, repeating = true })

-- Media control
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })

-- Brightness control
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- Screenshot keybindings
hl.bind("Print", hl.dsp.exec_cmd("~/.local/bin/scripts/screenshot.sh fullscreen"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("~/.local/bin/scripts/screenshot.sh smart"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.local/bin/scripts/screenshot.sh region"))
hl.bind(mainMod .. " + ALT + SHIFT + S", hl.dsp.exec_cmd("~/.local/bin/scripts/screenshot.sh window"))
hl.bind(mainMod .. " + ALT + Print", hl.dsp.exec_cmd("~/.local/bin/scripts/screenshot.sh monitor"))
hl.bind(mainMod .. " + CONTROL + Print", hl.dsp.exec_cmd("pkill hyprpicker || hyprpicker -a"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | tesseract stdin stdout | wl-copy && notify-send \"Screenshot OCR\" \"Text copied to clipboard\""))

-- Move/Change window focus
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Swap focused window with another
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }))
hl.bind("ALT + Tab", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Switch workspaces to a relative workspace
hl.bind(mainMod .. " + CONTROL + right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + CONTROL + left", hl.dsp.focus({ workspace = "r-1" }))

-- Move to the first empty workspace
hl.bind(mainMod .. " + CONTROL + down", hl.dsp.focus({ workspace = "empty" }))

-- Resize windows
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 30, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = -30, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -30 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 30 }), { repeating = true })

-- Move focused window to a workspace
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Move focused window to a relative workspace
hl.bind(mainMod .. " + CONTROL + ALT + right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CONTROL + ALT + left", hl.dsp.window.move({ workspace = "r-1" }))

-- Scroll through existing workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/Resize focused window
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + Z", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + X", hl.dsp.window.resize(), { mouse = true })

-- Clipboard history
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("qs msg clipboard toggle"))

-- Move/Switch to special workspace (scratchpad)
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special" }))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special())

-- Toggle focused window split
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Move focused window to a workspace silently
hl.bind(mainMod .. " + ALT + 1", hl.dsp.window.move({ workspace = 1, follow = false }))
hl.bind(mainMod .. " + ALT + 2", hl.dsp.window.move({ workspace = 2, follow = false }))
hl.bind(mainMod .. " + ALT + 3", hl.dsp.window.move({ workspace = 3, follow = false }))
hl.bind(mainMod .. " + ALT + 4", hl.dsp.window.move({ workspace = 4, follow = false }))
hl.bind(mainMod .. " + ALT + 5", hl.dsp.window.move({ workspace = 5, follow = false }))
hl.bind(mainMod .. " + ALT + 6", hl.dsp.window.move({ workspace = 6, follow = false }))
hl.bind(mainMod .. " + ALT + 7", hl.dsp.window.move({ workspace = 7, follow = false }))
hl.bind(mainMod .. " + ALT + 8", hl.dsp.window.move({ workspace = 8, follow = false }))
hl.bind(mainMod .. " + ALT + 9", hl.dsp.window.move({ workspace = 9, follow = false }))
hl.bind(mainMod .. " + ALT + 0", hl.dsp.window.move({ workspace = 10, follow = false }))

-- Theme selector
hl.bind(mainMod .. " + CONTROL + T", hl.dsp.exec_cmd("pkill wofi || ~/.local/bin/dotfiles-theme-select"))

-- QuickShell panels
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("qs msg notification-center toggle"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("qs msg control-center toggle"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("qs msg shell toggleBar"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("qs msg launcher toggle"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd("qs msg keybinds toggle"))
