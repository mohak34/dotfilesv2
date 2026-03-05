pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real brightness: 0
    property real maxBrightness: 0
    property string device: ""
    property real _lastBrightness: -1

    function setBrightness(percent) {
        var clamped = Math.max(0, Math.min(100, Math.round(percent)))
        setProcess.command = ["brightnessctl", "set", clamped + "%"]
        setProcess.running = true
    }

    function increase(step) {
        var s = step || 5
        setBrightness(brightness + s)
    }

    function decrease(step) {
        var s = step || 5
        setBrightness(brightness - s)
    }

    function reload() {
        readProcess.running = true
    }

    FileView {
        id: brightnessFile
        path: "/sys/class/backlight/amdgpu_bl1/brightness"
        watchChanges: true
        onFileChanged: this.reload()
        onLoaded: {
            if (root.maxBrightness <= 0) return
            var val = parseInt(this.text().trim())
            var newBrightness = Math.round(val / root.maxBrightness * 100)
            if (Math.abs(newBrightness - root._lastBrightness) > 0.5) {
                root._lastBrightness = newBrightness
                root.brightness = newBrightness
            }
        }
    }

    Process {
        id: readProcess
        command: ["brightnessctl", "-m"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                var parts = this.text.trim().split(",")
                if (parts.length >= 5) {
                    root.device = parts[0]
                    var max = parseInt(parts[4]) || 0
                    if (max > 0) root.maxBrightness = max
                    var pct = parts[3].replace("%", "")
                    var newBrightness = parseInt(pct) || 0
                    root._lastBrightness = newBrightness
                    root.brightness = newBrightness
                }
            }
        }
    }

    Process {
        id: setProcess
        running: false

        onExited: (exitCode, exitStatus) => {
            root.reload()
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.reload()
    }
}
