pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string connectionType: "disconnected"
    property string wifiSSID: ""
    property int wifiSignal: 0
    property string ip: ""
    property bool connected: false
    property string ethernetIface: ""
    property bool ethernetConnected: false

    readonly property string wifiIcon: {
        if (connectionType !== "wifi" || !connected) return "\uDB82\uDD2E"
        if (wifiSignal >= 67) return "\uDB82\uDD28"
        if (wifiSignal >= 34) return "\uDB82\uDD25"
        return "\uDB82\uDD22"
    }

    readonly property string networkIcon: {
        if (connectionType === "ethernet") return "\uDB80\uDE00"
        return wifiIcon
    }

    property var wifiNetworks: []
    property var vpnConnections: []
    property var _ssidToConnName: ({})
    property bool isScanning: false
    property bool isConnecting: false
    property string connectingSSID: ""
    property string connectionStatus: ""
    property bool wifiEnabled: true
    property bool wifiToggling: false
    property bool needsPassword: false
    property string passwordSSID: ""
    readonly property string wifiInterface: "wlan0"

    function refresh() {
        deviceStatusProcess.running = true
    }

    function scanWifi() {
        if (root.isScanning || !root.wifiEnabled) return
        root.isScanning = true
        wifiScanProcess.running = true
    }

    function connectToWifi(ssid) {
        root.isConnecting = true
        root.connectingSSID = ssid
        root.connectionStatus = "connecting"
        root.needsPassword = false
        root.passwordSSID = ""

        var connName = root._ssidToConnName[ssid]
        if (connName) {
            wifiConnectProcess.command = ["nice", "-n", "19", "ionice", "-c3",
                "nmcli", "connection", "up", connName]
        } else {
            wifiConnectProcess.command = ["nice", "-n", "19", "ionice", "-c3",
                "nmcli", "dev", "wifi", "connect", ssid]
        }
        wifiConnectProcess.running = true
    }

    function connectWithPassword(ssid, password) {
        root.isConnecting = true
        root.connectingSSID = ssid
        root.connectionStatus = "connecting"
        root.needsPassword = false
        root.passwordSSID = ""

        wifiConnectProcess.command = ["nice", "-n", "19", "ionice", "-c3",
            "nmcli", "dev", "wifi", "connect", ssid, "password", password]
        wifiConnectProcess.running = true
    }

    function disconnectWifi() {
        wifiDisconnectProcess.command = ["nice", "-n", "19", "ionice", "-c3",
            "nmcli", "dev", "disconnect", root.wifiInterface]
        wifiDisconnectProcess.running = true
    }

    function forgetWifi(ssid) {
        var connName = root._ssidToConnName[ssid] || ssid
        wifiForgetProcess.command = ["nice", "-n", "19", "ionice", "-c3",
            "nmcli", "connection", "delete", connName]
        wifiForgetProcess.running = true
    }

    function toggleWifiRadio() {
        if (root.wifiToggling) return
        root.wifiToggling = true
        var target = root.wifiEnabled ? "off" : "on"
        wifiRadioProcess.command = ["nice", "-n", "19", "ionice", "-c3",
            "nmcli", "radio", "wifi", target]
        wifiRadioProcess.running = true
    }

    function checkWifiEnabled() {
        wifiEnabledProcess.running = true
    }

    function refreshVpnList() {
        vpnListProcess.running = true
    }

    function connectVpn(name) {
        vpnToggleProcess.command = ["nice", "-n", "19", "ionice", "-c3",
            "nmcli", "con", "up", name]
        vpnToggleProcess.running = true
    }

    function disconnectVpn(name) {
        vpnToggleProcess.command = ["nice", "-n", "19", "ionice", "-c3",
            "nmcli", "con", "down", name]
        vpnToggleProcess.running = true
    }

    function cancelPassword() {
        root.needsPassword = false
        root.passwordSSID = ""
    }

    function splitNmcliFields(line) {
        var parts = []
        var cur = ""
        var esc = false
        for (var i = 0; i < line.length; i++) {
            var ch = line[i]
            if (esc) { cur += ch; esc = false }
            else if (ch === '\\') { esc = true }
            else if (ch === ':') { parts.push(cur); cur = "" }
            else { cur += ch }
        }
        parts.push(cur)
        return parts
    }

    Process {
        id: deviceStatusProcess
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION,DEVICE", "device", "status"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                var hasWifi = false
                var hasEthernet = false
                var wifiConn = ""
                var ethIface = ""
                var lines = this.text.trim().split("\n")

                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (!line) continue
                    var parts = line.split(":")
                    if (parts.length < 4) continue
                    var type = parts[0]
                    var state = parts[1]
                    var conn = parts[2]
                    var dev = parts[3]

                    if (type === "wifi" && state === "connected") {
                        hasWifi = true
                        wifiConn = conn
                    }
                    if (type === "ethernet" && state === "connected") {
                        hasEthernet = true
                        ethIface = dev
                    }
                }

                root.ethernetConnected = hasEthernet
                root.ethernetIface = ethIface

                if (hasEthernet) {
                    root.connectionType = "ethernet"
                    root.wifiSSID = ""
                    root.wifiSignal = 0
                    root.connected = true
                } else if (hasWifi) {
                    root.connectionType = "wifi"
                    root.wifiSSID = wifiConn
                    root.connected = true
                    wifiDetailProcess.running = true
                } else {
                    root.connectionType = "disconnected"
                    root.wifiSSID = ""
                    root.wifiSignal = 0
                    root.connected = false
                }
            }
        }
    }

    Process {
        id: wifiDetailProcess
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "device", "wifi", "list"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (!line) continue
                    var parts = line.split(":")
                    if (parts.length >= 3 && parts[0] === "yes") {
                        root.wifiSSID = parts[1]
                        root.wifiSignal = parseInt(parts[2]) || 0
                        return
                    }
                }
            }
        }
    }

    Process {
        id: wifiScanProcess
        command: ["nice", "-n", "19", "ionice", "-c3",
            "nmcli", "dev", "wifi", "rescan", "ifname", root.wifiInterface]
        running: false

        onExited: (exitCode, exitStatus) => {
            wifiListProcess.running = true
        }
    }

    Process {
        id: wifiListProcess
        command: ["nice", "-n", "19", "ionice", "-c3",
            "nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,BSSID", "dev", "wifi", "list",
            "ifname", root.wifiInterface]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var networks = []
                var seen = {}
                var lines = this.text.trim().split("\n")

                for (var i = 0; i < lines.length; i++) {
                    var parts = root.splitNmcliFields(lines[i])
                    if (parts.length >= 4 && parts[0]) {
                        var ssid = parts[0]
                        if (!seen[ssid]) {
                            seen[ssid] = true
                            networks.push({
                                ssid: ssid,
                                signal: parseInt(parts[1]) || 0,
                                secured: parts[2] !== "",
                                connected: ssid === root.wifiSSID,
                                saved: false
                            })
                        }
                    }
                }

                networks.sort(function(a, b) {
                    if (a.connected && !b.connected) return -1
                    if (!a.connected && b.connected) return 1
                    return b.signal - a.signal
                })

                root.wifiNetworks = networks
                savedConnectionsProcess.running = true
            }
        }
    }

    Process {
        id: savedConnectionsProcess
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var mapping = {}
                var lines = this.text.trim().split("\n")

                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (!line) continue
                    var parts = root.splitNmcliFields(line)
                    if (parts.length >= 2 && parts[1] === "802-11-wireless") {
                        mapping[parts[0]] = parts[0]
                    }
                }

                root._ssidToConnName = mapping

                var nets = root.wifiNetworks.slice()
                var changed = false
                for (var j = 0; j < nets.length; j++) {
                    if (mapping[nets[j].ssid] !== undefined) {
                        nets[j] = Object.assign({}, nets[j], { saved: true })
                        changed = true
                    }
                }

                if (changed) {
                    nets.sort(function(a, b) {
                        if (a.connected && !b.connected) return -1
                        if (!a.connected && b.connected) return 1
                        if (a.saved && !b.saved) return -1
                        if (!a.saved && b.saved) return 1
                        return b.signal - a.signal
                    })
                    root.wifiNetworks = nets
                }

                root.isScanning = false
            }
        }
    }

    Process {
        id: wifiConnectProcess
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.indexOf("successfully") >= 0) {
                    root.connectionStatus = "connected"
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                var errText = this.text.toLowerCase()
                if (errText.indexOf("password") >= 0 || errText.indexOf("secrets") >= 0 ||
                    errText.indexOf("auth") >= 0) {
                    root.connectionStatus = "auth_failed"
                    root.needsPassword = true
                    root.passwordSSID = root.connectingSSID
                } else if (this.text.trim()) {
                    root.connectionStatus = "failed"
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            root.isConnecting = false
            if (exitCode !== 0 && root.connectionStatus === "connecting") {
                root.connectionStatus = "failed"
            }
            root.connectingSSID = ""
            root.refresh()
            if (ShellState.controlCenterOpen) {
                Qt.callLater(root.scanWifi)
            }
        }
    }

    Process {
        id: wifiDisconnectProcess
        running: false

        onExited: (exitCode, exitStatus) => {
            root.refresh()
            if (ShellState.controlCenterOpen) {
                Qt.callLater(root.scanWifi)
            }
        }
    }

    Process {
        id: wifiForgetProcess
        running: false

        onExited: (exitCode, exitStatus) => {
            root.refresh()
            if (ShellState.controlCenterOpen) {
                Qt.callLater(root.scanWifi)
            }
        }
    }

    Process {
        id: wifiRadioProcess
        running: false

        onExited: (exitCode, exitStatus) => {
            root.wifiToggling = false
            root.checkWifiEnabled()
            root.refresh()
        }
    }

    Process {
        id: wifiEnabledProcess
        command: ["nmcli", "radio", "wifi"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = this.text.trim() === "enabled"
            }
        }
    }

    Process {
        id: vpnListProcess
        command: ["nmcli", "-t", "-f", "NAME,TYPE,ACTIVE", "con", "show"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var vpns = []
                var lines = this.text.trim().split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var parts = root.splitNmcliFields(lines[i])
                    if (parts.length >= 3 && parts[1] === "vpn") {
                        vpns.push({
                            name: parts[0],
                            active: parts[2] === "yes"
                        })
                    }
                }
                root.vpnConnections = vpns
            }
        }
    }

    Process {
        id: vpnToggleProcess
        running: false

        onExited: (exitCode, exitStatus) => {
            root.refreshVpnList()
            root.refresh()
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: {
        root.refresh()
        root.checkWifiEnabled()
    }
}
