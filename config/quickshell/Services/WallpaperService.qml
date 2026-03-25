pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentWallpaper: ""
    property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property bool useMatugen: true
    property bool wallpaperThemingEnabled: true
    property string currentPreset: ""
    property string colorScheme: "tonal-spot"

    property bool _awwwRunning: false
    readonly property string _matugenDir: Quickshell.env("HOME") + "/.config/matugen"
    readonly property string _colorsPath: _matugenDir + "/colors.json"

    readonly property var _presets: ({
        "Tokyo Night": {
            background:         "#1a1b26",
            surface:            "#24283b",
            surface_variant:    "#414868",
            primary:            "#7aa2f7",
            on_primary:         "#1a1b26",
            on_surface:         "#c0caf5",
            on_surface_variant: "#9aa5ce",
            outline:            "#565f89",
            outline_variant:    "#414868",
            error:              "#f7768e",
            tertiary:           "#e0af68",
            secondary:          "#7dcfff"
        },
        "Rosé Pine": {
            background:         "#191724",
            surface:            "#1f1d2e",
            surface_variant:    "#2a2837",
            primary:            "#c4a7e7",
            on_primary:         "#191724",
            on_surface:         "#e0def4",
            on_surface_variant: "#908caa",
            outline:            "#524f67",
            outline_variant:    "#403d52",
            error:              "#eb6f92",
            tertiary:           "#f6c177",
            secondary:          "#9ccfd8"
        },
        "Nord": {
            background:         "#2e3440",
            surface:            "#3b4252",
            surface_variant:    "#434c5e",
            primary:            "#88c0d0",
            on_primary:         "#2e3440",
            on_surface:         "#eceff4",
            on_surface_variant: "#d8dee9",
            outline:            "#4c566a",
            outline_variant:    "#434c5e",
            error:              "#bf616a",
            tertiary:           "#ebcb8b",
            secondary:          "#81a1c1"
        },
        "Gruvbox": {
            background:         "#282828",
            surface:            "#3c3836",
            surface_variant:    "#504945",
            primary:            "#d79921",
            on_primary:         "#282828",
            on_surface:         "#ebdbb2",
            on_surface_variant: "#bdae93",
            outline:            "#665c54",
            outline_variant:    "#504945",
            error:              "#cc241d",
            tertiary:           "#d65d0e",
            secondary:          "#458588"
        },
        "Catppuccin Mocha": {
            background:         "#1e1e2e",
            surface:            "#313244",
            surface_variant:    "#45475a",
            primary:            "#cba6f7",
            on_primary:         "#1e1e2e",
            on_surface:         "#cdd6f4",
            on_surface_variant: "#bac2de",
            outline:            "#585b70",
            outline_variant:    "#6c7086",
            error:              "#f38ba8",
            tertiary:           "#f9e2af",
            secondary:          "#89b4fa"
        }
    })

    Component.onCompleted: queryCurrentWallpaper()

    onUseMatugenChanged: {
        if (useMatugen)
            currentPreset = ""
        _applyWallpaperThemeIfReady()
    }

    onWallpaperThemingEnabledChanged: {
        _applyWallpaperThemeIfReady()
    }

    onCurrentWallpaperChanged: {
        if (!_awwwRunning)
            _applyWallpaperThemeIfReady()
    }

    onColorSchemeChanged: {
        _applyWallpaperThemeIfReady()
    }

    function queryCurrentWallpaper() {
        awwwQueryProcess.running = true
    }

    function setWallpaper(path) {
        if (_awwwRunning) return
        _awwwRunning = true
        currentPreset = ""
        currentWallpaper = path
        awwwImgProcess.command = ["awww", "img", path,
            "--transition-type", "fade",
            "--transition-duration", "1"]
        awwwImgProcess.running = true
    }

    function _applyWallpaperThemeIfReady() {
        if (!wallpaperThemingEnabled) return
        if (!useMatugen) return
        if (currentWallpaper === "") return
        _runMatugenJson(currentWallpaper)
    }

    function _runMatugenJson(path) {
        var schemeArg = root.colorScheme.startsWith("scheme-") ? root.colorScheme : "scheme-" + root.colorScheme
        matugenJsonProcess.command = ["matugen", "image", "--json", "hex", "-t", schemeArg, path]
        matugenJsonProcess.running = true
    }

    function applyPreset(name) {
        var p = _presets[name]
        if (!p) return
        currentPreset = name
        var json = JSON.stringify({
            colors: {
                background:         { dark: p.background },
                surface:            { dark: p.surface },
                surface_variant:    { dark: p.surface_variant },
                primary:            { dark: p.primary },
                on_primary:         { dark: p.on_primary },
                on_surface:         { dark: p.on_surface },
                on_surface_variant: { dark: p.on_surface_variant },
                outline:            { dark: p.outline },
                outline_variant:    { dark: p.outline_variant },
                error:              { dark: p.error },
                tertiary:           { dark: p.tertiary },
                secondary:          { dark: p.secondary }
            }
        }, null, 2)
        var escaped = json.replace(/'/g, "'\\''")
        writePresetProcess.command = [
            "bash", "-c",
            "mkdir -p " + root._matugenDir + " && echo '" + escaped + "' > " + root._colorsPath
        ]
        writePresetProcess.running = true
    }

    Process {
        id: awwwQueryProcess
        command: ["awww", "query"]

        stdout: StdioCollector {
            id: awwwQueryOut
            onStreamFinished: {
                var lines = awwwQueryOut.text.split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line.indexOf(": image: ") !== -1) {
                        var parts = line.split(": image: ")
                        if (parts.length >= 2) {
                            root.currentWallpaper = parts[1].trim()
                        }
                        break
                    }
                }
            }
        }
    }

    Process {
        id: awwwImgProcess

        onRunningChanged: {
            if (!running) {
                root._awwwRunning = false
                root._applyWallpaperThemeIfReady()
            }
        }
    }

    Process {
        id: matugenJsonProcess

        stdout: StdioCollector {
            id: matugenJsonOut
            onStreamFinished: {
                var text = matugenJsonOut.text.trim()
                if (text.length === 0) return
                try { JSON.parse(text) } catch(e) { return }
                var escaped = text.replace(/'/g, "'\\''")
                matugenWriteProcess.command = [
                    "bash", "-c",
                    "mkdir -p " + root._matugenDir + " && echo '" + escaped + "' > " + root._colorsPath
                ]
                matugenWriteProcess.running = true
            }
        }
    }

    Process {
        id: matugenWriteProcess

        onRunningChanged: {
            if (!running) {
                matugenTemplateProcess.command = ["matugen", "json", root._colorsPath]
                matugenTemplateProcess.running = true
            }
        }
    }

    Process {
        id: matugenTemplateProcess

        onRunningChanged: {
            if (!running) {
                hyprctlReloadProcess.running = true
            }
        }
    }

    Process {
        id: writePresetProcess

        onRunningChanged: {
            if (!running) {
                matugenPresetTemplateProcess.command = ["matugen", "json", root._colorsPath]
                matugenPresetTemplateProcess.running = true
            }
        }
    }

    Process {
        id: matugenPresetTemplateProcess

        onRunningChanged: {
            if (!running) {
                hyprctlReloadProcess.running = true
            }
        }
    }

    Process {
        id: hyprctlReloadProcess
        command: ["hyprctl", "reload"]
    }
}
