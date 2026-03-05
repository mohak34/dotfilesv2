import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property bool barAtTop: false
    property bool showMediaWidget: true
    property bool showBatteryPopup: true
    property bool showCalendar: true
    property bool gameModeEnabled: false
    readonly property bool animationsEnabled: !gameModeEnabled

    function setBarPosition(atTop: bool) {
        barAtTop = atTop
        saveSettings()
    }

    function toggleMediaWidget() {
        showMediaWidget = !showMediaWidget
        saveSettings()
    }

    function toggleBatteryPopup() {
        showBatteryPopup = !showBatteryPopup
        saveSettings()
    }

    function toggleCalendar() {
        showCalendar = !showCalendar
        saveSettings()
    }

    function setGameMode(enabled: bool) {
        gameModeEnabled = enabled
        if (enabled) {
            applyGameMode()
        } else {
            restoreNormalMode()
        }
        saveSettings()
    }

    function applyGameMode() {
        gameProcess.command = ["bash", "-c",
            "hyprctl keyword decoration:blur:enabled 0 && " +
            "hyprctl keyword decoration:dim_inactive true && " +
            "hyprctl keyword decoration:dim_strength 0.5"]
        gameProcess.running = true
    }

    function restoreNormalMode() {
        restoreProcess.command = ["bash", "-c",
            "hyprctl keyword decoration:blur:enabled 1 && " +
            "hyprctl keyword decoration:dim_inactive false && " +
            "hyprctl keyword decoration:dim_strength 0.5"]
        restoreProcess.running = true
    }

    Process { id: gameProcess }
    Process { id: restoreProcess }

    function loadSettings() {
        var file = Quickshell.appConfigPath + "/settings.json"
        var fileView = fileViewLoader.item
        if (fileView && fileView.loaded) {
            try {
                var data = JSON.parse(fileView.text())
                barAtTop = data.barAtTop ?? false
                showMediaWidget = data.showMediaWidget ?? true
                showBatteryPopup = data.showBatteryPopup ?? true
                showCalendar = data.showCalendar ?? true
                gameModeEnabled = data.gameModeEnabled ?? false
            } catch (e) {
                console.log("Failed to parse settings:", e)
            }
        }
    }

    function saveSettings() {
        var data = {
            barAtTop: barAtTop,
            showMediaWidget: showMediaWidget,
            showBatteryPopup: showBatteryPopup,
            showCalendar: showCalendar,
            gameModeEnabled: gameModeEnabled
        }
        saveProcess.command = ["bash", "-c", "echo '" + JSON.stringify(data) + "' > " + Quickshell.appConfigPath + "/settings.json"]
        saveProcess.running = true
    }

    Process {
        id: saveProcess
    }

    Loader {
        id: fileViewLoader
        active: true
        sourceComponent: FileView {
            path: Quickshell.appConfigPath + "/settings.json"
            onLoaded: root.loadSettings()
        }
    }
}
