pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool active: false

    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: checkProcess.running = true
    }

    Process {
        id: checkProcess
        command: ["pgrep", "-x", "gammastep"]
        running: false
        onExited: (exitCode, exitStatus) => {
            root.active = (exitCode === 0)
        }
    }

    Process {
        id: startProcess
        command: ["gammastep", "-O", "4500"]
        running: false
        onExited: checkProcess.running = true
    }

    Process {
        id: stopProcess
        command: ["pkill", "-x", "gammastep"]
        running: false
        onExited: {
            root.active = false
        }
    }

    function toggle() {
        if (active) {
            stopProcess.running = true
        } else {
            startProcess.running = true
            active = true
        }
    }
}
