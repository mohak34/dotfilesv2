pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: (adapter && adapter.enabled) ?? false
    readonly property bool discovering: (adapter && adapter.discovering) ?? false

    readonly property var connectedDevices: {
        if (!adapter || !adapter.devices) return []
        return adapter.devices.values.filter(dev => dev.connected)
    }

    readonly property int connectedCount: connectedDevices.length

    readonly property var pairedDevices: {
        if (!adapter || !adapter.devices) return []
        return adapter.devices.values.filter(dev => dev.paired || dev.trusted)
    }

    readonly property string icon: {
        if (!available || !enabled) return "\udb80\udcb2"
        if (connectedCount > 0) return "\udb80\udcb1"
        return "\udb80\udcaf"
    }

    function toggleBluetooth() {
        if (!adapter) return
        adapter.enabled = !adapter.enabled
    }

    function startScan() {
        if (!adapter) return
        adapter.discovering = true
    }

    function stopScan() {
        if (!adapter) return
        adapter.discovering = false
    }

    function connectDevice(device) {
        if (!device) return
        device.trusted = true
        device.connect()
    }

    function disconnectDevice(device) {
        if (!device) return
        device.disconnect()
    }

    function getDeviceIcon(device) {
        if (!device) return "\udb80\udcaf"
        var name = (device.name || "").toLowerCase()
        var icon = (device.icon || "").toLowerCase()

        if (icon.includes("headset") || icon.includes("audio") || name.includes("headphone") || name.includes("airpod"))
            return "\udb80\udecf"
        if (icon.includes("mouse") || name.includes("mouse"))
            return "\udb82\udda8"
        if (icon.includes("keyboard") || name.includes("keyboard"))
            return "\udb80\ude18"
        if (icon.includes("phone") || name.includes("phone"))
            return "\udb80\udddf"
        if (icon.includes("speaker") || name.includes("speaker"))
            return "\udb81\udd7e"

        return "\udb80\udcaf"
    }
}
