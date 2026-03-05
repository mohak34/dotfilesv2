pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property real sinkVolume: sink?.audio ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool sinkMuted: sink?.audio?.muted ?? true
    readonly property string sinkName: {
        if (!sink) return ""
        if (sink.description && sink.description !== sink.name)
            return sink.description
        if (sink.properties?.["node.description"])
            return sink.properties["node.description"]
        return sink.name ?? ""
    }
    readonly property string activePort: _activePort
    property string _activePort: ""
    readonly property bool isHeadphone: 
        _activePort.includes("headphone") || _activePort.includes("headset")
    readonly property string sinkIcon: {
        if (root.isHeadphone) return "headset"
        return sinkIconForNode(sink)
    }

    readonly property real sourceVolume: source?.audio ? Math.round(source.audio.volume * 100) : 0
    readonly property bool sourceMuted: source?.audio?.muted ?? true
    readonly property string sourceName: {
        if (!source) return ""
        if (source.description && source.description !== source.name)
            return source.description
        if (source.properties?.["node.description"])
            return source.properties["node.description"]
        return source.name ?? ""
    }
    readonly property string sourceIcon: {
        if (!source?.audio) return "\udb80\udf6d"
        if (source.audio.muted) return "\udb80\udf6d"
        return "\udb80\udf6c"
    }

    function setSinkVolume(percent) {
        if (!sink?.audio) return
        sink.audio.volume = Math.max(0, Math.min(100, percent)) / 100
    }

    function toggleSinkMute() {
        if (!sink?.audio) return
        sink.audio.muted = !sink.audio.muted
    }

    function adjustSinkVolume(delta) {
        if (!sink?.audio) return
        if (sink.audio.muted) sink.audio.muted = false
        var current = Math.round(sink.audio.volume * 100)
        var next = Math.max(0, Math.min(100, current + delta))
        sink.audio.volume = next / 100
    }

    function setSourceVolume(percent) {
        if (!source?.audio) return
        source.audio.volume = Math.max(0, Math.min(100, percent)) / 100
    }

    function toggleSourceMute() {
        if (!source?.audio) return
        source.audio.muted = !source.audio.muted
    }

    function getAvailableSinks() {
        return Pipewire.nodes.values.filter(node => node.audio && node.isSink && !node.isStream)
    }

    function cycleSinkOutput() {
        var sinks = getAvailableSinks()
        if (sinks.length < 2) return
        var currentName = sink?.name ?? ""
        var currentIndex = sinks.findIndex(s => s.name === currentName)
        var nextIndex = (currentIndex + 1) % sinks.length
        Pipewire.preferredDefaultAudioSink = sinks[nextIndex]
    }

    function displayName(node) {
        if (!node) return ""
        if (node.description && node.description !== node.name)
            return node.description
        var nd = node.properties?.["node.description"] ?? ""
        if (nd) return nd
        return node.name ?? ""
    }

    function streamDisplayName(node) {
        if (!node) return ""
        var app = node.properties?.["application.name"] ?? ""
        var media = node.properties?.["media.name"] ?? ""
        if (app && media) return app + ": " + media
        if (app) return app
        if (media) return media
        return displayName(node)
    }

    function sinkIconForNode(node) {
        if (!node) return "speaker"
        var props = node.properties || {}
        var formFactor = (props["device.form-factor"] || "").toLowerCase()

        switch (formFactor) {
        case "headphone":
        case "headset":
        case "hands-free":
        case "handset":
            return "headset"
        case "tv":
        case "monitor":
            return "tv"
        case "speaker":
        case "computer":
        case "hifi":
        case "portable":
        case "car":
            return "speaker"
        }

        var bus = (props["device.bus"] || "").toLowerCase()
        if (bus === "bluetooth") return "headset"

        var name = (node.name || "").toLowerCase()
        if (name.includes("hdmi")) return "tv"
        if (name.includes("iec958") || name.includes("spdif")) return "speaker"
        if (name.includes("headphone") || name.includes("headset")) return "headset"
        if (bus === "usb") return "headset"

        return "speaker"
    }

    Process {
        id: portCheckProcess
        command: ["bash", "-c", "pactl list sinks | grep 'Active Port' | head -1"]
        stdout: SplitParser {
            onRead: (line) => {
                root._activePort = line.toLowerCase()
            }
        }
    }

    Timer {
        id: portCheckTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: portCheckProcess.running = true
    }

    PwObjectTracker {
        objects: Pipewire.nodes.values.filter(
            node => node.audio && (!node.isStream || (node.isSink && node.isStream))
        )
    }
}
