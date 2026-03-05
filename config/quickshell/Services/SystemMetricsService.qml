pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real cpuPercent: 0
    property real ramPercent: 0
    property real ramUsedGb: 0
    property real ramTotalGb: 0

    property var prevCpuTotal: 0
    property var prevCpuIdle: 0

    function parseCpuStat(text) {
        var lines = text.trim().split("\n")
        if (lines.length === 0) return

        var firstLine = lines[0]
        if (!firstLine.startsWith("cpu ")) return

        var parts = firstLine.replace(/\s+/g, " ").split(" ")
        if (parts.length < 8) return

        var user = parseInt(parts[1]) || 0
        var nice = parseInt(parts[2]) || 0
        var system = parseInt(parts[3]) || 0
        var idle = parseInt(parts[4]) || 0
        var iowait = parseInt(parts[5]) || 0
        var irq = parseInt(parts[6]) || 0
        var softirq = parseInt(parts[7]) || 0
        var steal = parseInt(parts[8]) || 0

        var total = user + nice + system + idle + iowait + irq + softirq + steal
        var idleTotal = idle + iowait

        if (prevCpuTotal > 0) {
            var deltaTotal = total - prevCpuTotal
            var deltaIdle = idleTotal - prevCpuIdle
            if (deltaTotal > 0) {
                root.cpuPercent = Math.round(((deltaTotal - deltaIdle) / deltaTotal) * 100)
            }
        }

        prevCpuTotal = total
        prevCpuIdle = idleTotal
    }

    function parseMemInfo(text) {
        var lines = text.trim().split("\n")
        var memTotal = 0
        var memAvailable = 0

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            if (line.startsWith("MemTotal:")) {
                memTotal = parseInt(line.replace(/[^0-9]/g, "")) || 0
            } else if (line.startsWith("MemAvailable:")) {
                memAvailable = parseInt(line.replace(/[^0-9]/g, "")) || 0
            }
            if (memTotal > 0 && memAvailable > 0) break
        }

        if (memTotal > 0) {
            root.ramTotalGb = memTotal / 1048576
            var used = memTotal - memAvailable
            root.ramUsedGb = used / 1048576
            root.ramPercent = Math.round((used / memTotal) * 100)
        }
    }

    Process {
        id: cpuProcess
        command: ["sh", "-c", "head -1 /proc/stat"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.parseCpuStat(this.text)
        }
    }

    Process {
        id: memProcess
        command: ["sh", "-c", "grep -E '^(MemTotal|MemAvailable):' /proc/meminfo"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.parseMemInfo(this.text)
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProcess.running = true
            memProcess.running = true
        }
    }
}
