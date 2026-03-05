import QtQuick
import Quickshell
import Quickshell.Io
import qs.Modules.Bar
import qs.Modules.Notifications
import qs.Modules.ControlCenter
import qs.Modules.Calendar
import qs.Modules.Launcher
import qs.Modules.Clipboard
import qs.Services

Item {
    Variants {
        model: Quickshell.screens

        delegate: Bar {
            required property var modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: NotificationPopups {
            required property var modelData
            screen: modelData
        }
    }

    ControlCenter {}
    NotificationCenter {}
    Calendar {}
    BatteryPopup {}
    Launcher {}
    ClipboardPopup {}

    IpcHandler {
        target: "notification-center"

        function toggle(): string {
            ShellState.toggleNotificationCenter()
            return "OK"
        }

        function open(): string {
            ShellState.openNotificationCenter()
            return "OK"
        }

        function close(): string {
            ShellState.closeNotificationCenter()
            return "OK"
        }
    }

    IpcHandler {
        target: "control-center"

        function toggle(): string {
            if (ShellState.controlCenterOpen)
                ShellState.closeControlCenter()
            else {
                ShellState.ccTriggerX = 0
                ShellState.ccTriggerWidth = 0
                ShellState.openTab("cc")
            }
            return "OK"
        }

        function open(): string {
            ShellState.ccTriggerX = 0
            ShellState.ccTriggerWidth = 0
            ShellState.openTab("cc")
            return "OK"
        }

        function close(): string {
            ShellState.closeControlCenter()
            return "OK"
        }
    }

    IpcHandler {
        target: "shell"

        function toggleBar(): string {
            ShellState.toggleBar()
            return ShellState.barVisible ? "shown" : "hidden"
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): string {
            ShellState.toggleLauncher()
            return ShellState.launcherOpen ? "opened" : "closed"
        }

        function open(): string {
            ShellState.openLauncher()
            return "opened"
        }

        function close(): string {
            ShellState.closeLauncher()
            return "closed"
        }
    }

    IpcHandler {
        target: "clipboard"

        function toggle(): string {
            ShellState.toggleClipboard()
            return ShellState.clipboardOpen ? "opened" : "closed"
        }

        function open(): string {
            ShellState.openClipboard()
            return "opened"
        }

        function close(): string {
            ShellState.closeClipboard()
            return "closed"
        }
    }
}
