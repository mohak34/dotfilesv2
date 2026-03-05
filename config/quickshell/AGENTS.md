# Quickshell Rice — AGENTS.md

## Project Overview

A custom Quickshell (QML) shell for Hyprland on an ASUS ROG G15 2022 laptop.
Built from scratch, cherry-picking and adapting code from DankMaterialShell (DMS)
as reference. DMS is cloned at ~/DankMaterialShell for reference — never copy-paste
blindly, always adapt to remove DMS-specific dependencies.

## System Context

- **Compositor:** Hyprland (dwindle layout)
- **Hardware:** ASUS ROG G15 2022, AMD CPU + NVIDIA GPU (hybrid graphics)
- **Distro:** Arch Linux
- **Package manager:** pacman + AUR (yay)
- **Hyprland borders:** 1px border, rounding 10px, gaps_in 1, gaps_out 2
- **Bar position:** Bottom, full-width, 27px height
- **Fonts:** JetBrainsMono Nerd Font, 12px, Bold (nerd font icons for all widget icons)
- **Animations:** Hyprland animations are enabled (easeOutQuint etc.)
- **asusctl/asusd:** installed and running (D-Bus not activatable via busctl but service is active)
- **supergfxd:** installed and running
- **Charge limit sysfs:** /sys/class/power_supply/BAT0/charge_control_end_threshold (currently 80)
- **Platform profiles:** quiet, balanced, performance (via /sys/firmware/acpi/platform_profile)
- **powerprofilesctl:** NOT installed
- **Bluetooth:** rfkilled, not needed in bar but has toggle tile in control center

## Reference Material

- **DMS source:** ~/DankMaterialShell (cloned, read-only reference)
- **Matugen colors:** Generated from wallpaper using Material You algorithm.
  - Output: ~/.config/matugen/colors.json (full Material 3 tonal palette)
  - Run: matugen image /path/to/wallpaper.jpg
  - Theme.qml reads this JSON directly — no intermediate template files needed
- **Hyprland config:** ~/.config/hypr/ (modular, split across multiple .conf files)
  - appearance.conf — borders, rounding, blur, shadows
  - keybinds.conf — existing keybinds (Super+N = NC, Super+Shift+A = CC)

## Architecture

```
~/.config/quickshell/
├── AGENTS.md                           # This file
├── shell.qml                           # Entry point (ShellRoot)
├── Shell.qml                           # Root orchestrator (IPC handlers, component instances)
├── Common/
│   ├── qmldir
│   ├── Appearance.qml                  # Static design tokens (spacing, rounding, animation, pill, popout)
│   └── Theme.qml                       # Dynamic colors (matugen + catppuccin mocha fallback)
├── Services/
│   ├── qmldir                          # 11 singletons
│   ├── AudioService.qml               # Quickshell Pipewire bindings (native)
│   ├── BatteryService.qml             # UPower bindings (native)
│   ├── BluetoothService.qml           # Quickshell Bluetooth bindings (native)
│   ├── BrightnessService.qml          # brightnessctl + FileView inotify on sysfs
│   ├── NetworkService.qml             # nmcli shell-outs (WiFi scan/connect/forget, VPN, radio toggle)
│   ├── NightLightService.qml          # gammastep toggle (pgrep/pkill)
│   ├── NotificationService.qml        # NotificationServer + OSD + DND + popup management
│   ├── ShellState.qml                 # CC/NC open state (independent), DND, trigger positions, expandedDetail, activeTab
│   ├── SystemMetricsService.qml       # /proc polling (CPU%, RAM%)
│   └── WallpaperService.qml           # swww img + matugen, currentWallpaper, useMatugen flag
├── Modules/
│   ├── Bar/
│   │   ├── qmldir
│   │   ├── Bar.qml                    # Bottom PanelWindow, pills layout
│   │   └── Widgets/
│   │       ├── qmldir
│   │       ├── AudioWidget.qml        # Volume icon + mic indicator
│   │       ├── Battery.qml            # Battery icon + percentage
│   │       ├── BluetoothWidget.qml    # Bluetooth icon (rfkilled, hidden)
│   │       ├── Clock.qml             # Time display
│   │       ├── CpuRamMonitor.qml     # CPU% + RAM%
│   │       ├── NetworkWidget.qml      # Network icon, click triggers CC
│   │       ├── NotificationBell.qml   # Bell icon, DND indicator, click triggers NC
│   │       ├── SystemTray.qml         # System tray icons
│   │       └── Workspaces.qml         # Hyprland workspace indicators
│   ├── Notifications/
│   │   ├── qmldir
│   │   ├── NotificationCard.qml       # Single notification card component
│   │   ├── NotificationCenter.qml     # Right-side panel (bell icon trigger, Super+N, full height minus bar)
│   │   ├── NotificationPopups.qml     # Toast notification stack
│   │   └── OsdCard.qml               # Volume/brightness OSD overlay
│   └── ControlCenter/
│       ├── qmldir
│       ├── ControlCenter.qml          # Floating popup with 2 tabs: CC + Wallpaper (network icon trigger, Super+Shift+A)
│       ├── SliderControl.qml          # Reusable slider component
│       ├── ToggleTile.qml             # 2-zone grid tile (icon toggle + text/detail)
│       ├── AudioOutputSection.qml     # Audio output device list + per-app playback streams
│       ├── AudioInputSection.qml      # Audio input device picker detail panel
│       ├── BluetoothSection.qml       # BT device list detail panel
│       ├── WiFiSection.qml            # WiFi network list detail panel
│       ├── VpnSection.qml            # VPN profile connect/disconnect
│       └── WallpaperSection.qml       # Fixed-size thumbnail grid (150px cells, 3x5 viewport) + Theme Source toggle
```

## Build Phases

| Phase | Status | Summary |
|-------|--------|---------|
| 1 - Skeleton + Bar | COMPLETE | Bottom bar with workspaces + clock |
| 2 - System Widgets | COMPLETE | 6 services, 6 widgets, system tray, icon audit |
| 2.5 - Bar Polish | COMPLETE | Pills, spacing, tray, SSID removal, mic indicator |
| 3 - Notifications + OSD | COMPLETE | Popups, center, OSD cards, brightness inotify, bell icon, IPC |
| 4 - Control Center | COMPLETE | WiFi/VPN management, volume/brightness sliders |
| 4 Polish | COMPLETE | Floating popups, grid tiles, BT/NightLight/DND toggles |
| 4.5 Audio | COMPLETE | Mic tile, mic slider, audio output detail, per-app streams |
| 4.6 Audio Input | COMPLETE | Mic input device picker detail panel |
| 4.7 Wallpaper | COMPLETE | swww thumbnail grid, Theme Source toggle, matugen integration |
| 4.8 Tabbed Popup | COMPLETE | CC + Notifications + Wallpaper merged into one tabbed popup |
| 4.9 NC Split + WP Fix | COMPLETE | NC back to standalone right-side panel; CC 2 tabs; fixed wallpaper grid |
| 5 - Theming Polish | COMPLETE | Theme.qml loadColors fix, preset themes (5 presets), Matugen scheme selector (tonal/mono/neutral/vibrant), Light theme upgrade (state layers, container colors) |
| 6 - Visual Polish | COMPLETE | Bar cleanup (removed CPU/RAM, increased pill opacity, reduced icon sizes), AudioWidget simplification, Headphone icon detection fix (SplitParser), Pill color visibility fix |
| 7 - Popups + Calendar | COMPLETE | CC popup positioning fix, Calendar popup (click on clock), Battery popup with stats grid (Status/Power/Time/Health), All popups stick to bar |
| 8 - Settings + Game Mode | IN PROGRESS | Settings panel in CC, Game mode toggle (disables blur/animations via hyprctl) |

## Future Work
- Clipboard integration (use rofi + cliphist, already installed)
- Additional polish items as needed

## Popup Architecture

### Control Center (floating popup)

550px wide floating popup with 2 tabs: "Control Center" | "Wallpaper".
Click-outside-to-close via full-screen transparent overlay.

**Window setup:**
- PanelWindow anchors all 4 sides (full-screen transparent overlay)
- WlrLayershell.layer: WlrLayer.Overlay
- WlrLayershell.exclusiveZone: -1
- Outer MouseArea catches clicks-outside-to-close
- Inner Rectangle positioned at computed X/Y with the popup content
- Inner MouseArea on popup Rectangle prevents click-through

**Positioning (bottom bar):**
```javascript
popupX = clamp(gap, triggerCenterX - popupWidth/2, screenWidth - popupWidth - gap)
popupY = screenHeight - barHeight - gap - popupHeight
```

NetworkWidget computes screen X via `mapToItem(null, 0, 0).x` and stores in ShellState before toggling.

**No animations on open/close** -- popups appear/close instantly.

### Notification Center (right-side panel)

380px wide side panel anchored to right edge, full screen height minus bar.

**Window setup:**
- PanelWindow anchors top + right + bottom (NO left anchor)
- Width: Appearance.popout.ncWidth (380px)
- WlrLayershell.layer: WlrLayer.Overlay
- WlrLayershell.exclusiveZone: -1
- Inner Rectangle has anchors.bottomMargin: Appearance.barHeight (27px) to avoid covering bar
- Bell icon toggles ShellState.notificationCenterOpen (independent from CC)
- CC and NC can coexist simultaneously (different sides of screen)

## Control Center Layout

550px wide floating popup with 2 tabs:

**CC Tab:**
1. Header row (title + close button)
2. 3x2 toggle tile grid: WiFi, Bluetooth, Night Light, DND, Audio Output, Microphone
3. Expandable detail area (WiFiSection, BluetoothSection, AudioOutputSection, AudioInputSection)
4. Volume slider (inline SliderControl)
5. Microphone slider (inline SliderControl)
6. Brightness slider (inline SliderControl)
7. VPN section (visible when vpnConnections.length > 0)

**Wallpaper Tab:**
- Theme Source row (Wallpaper/Preset pills)
- Fixed-size thumbnail grid: 3 columns, 150px cells, 8px gaps
- Flickable viewport height: 782px (shows ~5 rows)
- Scroll to browse remaining wallpapers
- Custom scrollbar indicator on right edge

Audio Output detail panel shows:
- Output device list (click to switch default sink)
- Playback streams with per-app volume sliders and mute toggles

## Notification Center Layout

380px wide right-side panel with:
1. Header (title + clear all button + close button)
2. Divider
3. Empty state text (when no notifications)
4. Flickable wrapping ListView of live notifications + history
5. Full screen height minus 27px bar

## Theming System

### Color Sources (priority order)
1. **Matugen** -- primary. Full Material 3 tonal palette from wallpaper.
   - Output: ~/.config/matugen/colors.json
   - Theme.qml reads + watches this file for live reload
2. **Catppuccin Mocha** -- hardcoded fallback when matugen colors.json doesn't exist

### Theme.qml Color Tokens
Mapped from matugen colors.json (dark scheme keys):
- background, surface, surfaceVariant (note: property named `surfaceVariantText` to avoid QML clash)
- primary, primaryText (avoids `onPrimary` clash), secondaryContainer
- surfaceText (avoids `onSurface` clash), outline, outlineVariant
- error, inverseSurface
- `withAlpha(color, alpha)` helper function

### Appearance.qml Constants
- Bar height: 27px
- Rounding: normal=10, small=6, large=16
- Spacing: 4, 8, 12, 16, 24
- Pill: height=23, hPad=8, spacing=2, rounding=8
- Popout: radius=12, gap=8, contentMargin=16, ccWidth=550, ncWidth=380
- Animation: quick=150ms, normal=250ms, slow=350ms

## Key Technical Rules

### QML Imports
- Module namespace: qs.Common, qs.Services, qs.Modules.Bar, etc.
- Each directory needs a qmldir file declaring the module
- Singletons need `pragma Singleton` + entry in qmldir
- Named module imports mandatory -- `import "../Common"` does NOT work

### Services Pattern
- All services are `pragma Singleton` QML objects
- Services talk to system via native Quickshell bindings or Process for CLI tools
- Services expose only reactive properties and simple functions -- no UI logic
- Audio: Quickshell.Services.Pipewire (native)
- Battery: Quickshell.Services.UPower (native)
- Bluetooth: Quickshell.Bluetooth (native)
- Notifications: Quickshell.Services.Notifications (native)
- SystemTray: Quickshell.Services.SystemTray (native)
- Network: nmcli shell-outs (LegacyNetworkService pattern from DMS)
- Brightness: brightnessctl via Process + FileView inotify on sysfs

### IPC
- Quickshell built-in IPC from `Quickshell.Io`
- Define `target` + functions in QML
- Call externally with `qs msg <target> <function>`
- Used for: Super+N (toggleNotificationCenter), Super+Shift+A (toggleControlCenter)
- Keybinds in ~/.config/hypr/keybinds.conf

### Bar Widget Pattern
- Each widget is a self-contained QML component
- Takes barHeight as property from parent
- Uses Theme.qml color tokens -- never hardcode colors
- Uses Appearance.qml for spacing/rounding -- never hardcode sizes
- Widgets arranged in pills (grouped rounded containers)

## QML Gotchas (Critical)

1. **`on[A-Z]` property name clash** -- QML interprets `onSurface` as signal handler. Use `surfaceText`, `primaryText`, `surfaceVariantText` instead.
2. **Named module imports mandatory** -- `import "../Common"` does NOT work. Must use `import qs.Common` with qmldir files.
3. **FileView API** -- `text()` is a function not a property. `loaded` is both bool and signal.
4. **PanelWindow layers** -- `WlrLayer.Bottom` puts bar BEHIND windows. Use `WlrLayer.Top` for bar, `WlrLayer.Overlay` for notifications/control center.
5. **StdioCollector** -- For multi-line Process output, use `StdioCollector` with `onStreamFinished`, NOT `SplitParser`. `text` on StdioCollector IS a property (unlike FileView).
6. **Pill visibility bug** -- Binding pill `visible: childWidget.visible` breaks when child has its own `visible` binding. Bind pill `visible` directly to service data.
7. **Special workspaces** -- Hyprland special workspaces have negative IDs (e.g., -99). Filter with `wsId > 0`.
8. **UPower percentage** -- `UPowerDevice.percentage` is 0.0-1.0 float, must multiply by 100.
9. **Timestamp overflow** -- `Date.now()` returns ~1.77 trillion, overflows QML `int` (32-bit). Use `property real timestamp`.
10. **`brightnessctl -m` field order** -- Output is `device,class,current_raw,percentage%,max_raw`. parts[3]=percentage, parts[4]=max.
11. **Notification duplication** -- Each notification goes to both `notifications[]` (live) and `history[]` (persistent). Skip history items whose timestamps match live notifications.
12. **IpcHandler** -- Quickshell built-in IPC from `Quickshell.Io`. Define `target` + functions in QML, call externally with `qs msg <target> <function>`.
13. **Signal name clash with properties** -- `signal valueChanged(real newValue)` clashes with auto-generated `onValueChanged` from `property real value`. Rename to `sliderMoved` or similar.
14. **`stderr` on Process** -- Confirmed supported. DMS uses `stderr: StdioCollector` in 6+ files.

## Nerd Font Icon Codepoints (Verified)

- Bell: `\uDB80\uDC9A` / Bell-off (DND): `\uDB80\uDC9B`
- Brightness (sun): `\uDB80\uDCE0`
- Night Light: `\uDB80\uDD89`
- Volume: `\uDB81\uDD7E` (high), `\uDB81\uDD80` (low), `\uDB81\uDD7F` (off), `\uDB81\uDF5F` (muted)
- VPN: `\uDB81\uDD82`
- WiFi: `\uDB82\uDD28`

## Commands

- **Run shell:** qs -p ~/.config/quickshell
- **Hot reload:** Quickshell watches files automatically (edit and save = live reload)
- **DMS reference:** ls ~/DankMaterialShell/quickshell/
- **Matugen colors:** matugen image /path/to/wallpaper.jpg
- **IPC toggle NC:** qs msg shell toggleNotificationCenter
- **IPC toggle CC:** qs msg shell toggleControlCenter

## What NOT to Build

- No greeter / login screen (use SDDM separately)
- No lock screen (user keeps hyprlock)
- No plugin system
- No DMS IPC socket or Go binary
- No standalone dock (separate from bar)
- No weather widget in bar
- No notepad widget
- No color picker widget
- No DWL / niri / Sway support -- Hyprland only
- No wallust integration (using matugen instead)
- No dgop (using /proc instead)
- No AudioVisualization / cava widget
- No DankDash / dashboard panel
- No SSID in network widget (icon only in bar)
- No Bluetooth widget in bar (rfkilled)
- No power-profiles-daemon (powerprofilesctl not installed)
