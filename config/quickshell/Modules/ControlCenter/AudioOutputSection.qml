import QtQuick
import Quickshell.Services.Pipewire
import qs.Common
import qs.Services

Column {
    id: root
    spacing: 6
    width: parent?.width ?? 0

    readonly property var sinkList: {
        var result = []
        var nodes = Pipewire.nodes.values
        for (var i = 0; i < nodes.length; i++) {
            if (nodes[i].audio && nodes[i].isSink && !nodes[i].isStream)
                result.push(nodes[i])
        }
        return result
    }

    readonly property var streamList: {
        var result = []
        var nodes = Pipewire.nodes.values
        for (var i = 0; i < nodes.length; i++) {
            if (nodes[i].audio && nodes[i].isSink && nodes[i].isStream)
                result.push(nodes[i])
        }
        return result
    }

    Text {
        text: "Output Devices"
        color: Theme.surfaceVariantText
        font.family: Appearance.fontFamily
        font.pixelSize: 10
        font.weight: Font.Bold
    }

    Column {
        width: parent.width
        spacing: 2

        Repeater {
            model: root.sinkList

            delegate: Rectangle {
                id: deviceDelegate

                required property var modelData
                width: deviceDelegate.parent?.width ?? 0
                height: 36
                radius: 6
                color: deviceMouse.containsMouse
                    ? Theme.withAlpha(Theme.surfaceVariant, 0.3)
                    : "transparent"

                readonly property bool isActive: modelData === AudioService.sink

                readonly property string deviceName: {
                    if (!modelData) return ""
                    return AudioService.displayName(modelData)
                }

                readonly property string deviceIcon: {
                    var kind = AudioService.sinkIconForNode(modelData)
                    switch (kind) {
                    case "headset": return "\udb80\udecb"
                    case "tv": return "\udb82\udc42"
                    default: return "\udb81\udd7e"
                    }
                }

                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 8
                    spacing: 8

                    Text {
                        text: deviceDelegate.deviceIcon
                        color: deviceDelegate.isActive ? Theme.primary : Theme.surfaceText
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSize + 2
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: deviceDelegate.deviceName
                        color: deviceDelegate.isActive ? Theme.primary : Theme.surfaceText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 11
                        font.weight: deviceDelegate.isActive ? Font.Bold : Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        width: Math.max(0, parent.width - 80)
                    }

                    Text {
                        visible: deviceDelegate.isActive
                        text: "Active"
                        color: Theme.primary
                        font.family: Appearance.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: deviceMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!deviceDelegate.isActive)
                            Pipewire.preferredDefaultAudioSink = deviceDelegate.modelData
                    }
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.withAlpha(Theme.outline, 0.1)
        visible: root.streamList.length > 0
    }

    Text {
        visible: root.streamList.length > 0
        text: "Playback"
        color: Theme.surfaceVariantText
        font.family: Appearance.fontFamily
        font.pixelSize: 10
        font.weight: Font.Bold
    }

    Column {
        width: parent.width
        spacing: 4
        visible: root.streamList.length > 0

        Repeater {
            model: root.streamList

            delegate: Rectangle {
                id: streamDelegate

                required property var modelData
                width: streamDelegate.parent?.width ?? 0
                implicitHeight: streamCol.implicitHeight + 12
                radius: 6
                color: Theme.withAlpha(Theme.surfaceVariant, 0.15)

                readonly property string streamName: AudioService.streamDisplayName(modelData)
                readonly property real streamVolume: modelData.audio
                    ? Math.round(modelData.audio.volume * 100) : 0
                readonly property bool streamMuted: modelData.audio?.muted ?? false

                readonly property string streamVolumeIcon: {
                    if (streamDelegate.streamMuted) return "\uDB81\uDF5F"
                    if (streamDelegate.streamVolume <= 0) return "\uDB81\uDD7F"
                    if (streamDelegate.streamVolume < 50) return "\uDB81\uDD80"
                    return "\uDB81\uDD7E"
                }

                Column {
                    id: streamCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 8
                    y: 6
                    spacing: 4

                    Text {
                        text: streamDelegate.streamName
                        color: Theme.surfaceText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    SliderControl {
                        width: parent.width
                        value: streamDelegate.streamVolume
                        icon: streamDelegate.streamVolumeIcon
                        muted: streamDelegate.streamMuted
                        onSliderMoved: newValue => {
                            if (streamDelegate.modelData.audio) {
                                streamDelegate.modelData.audio.volume = newValue / 100
                                if (newValue > 0 && streamDelegate.modelData.audio.muted)
                                    streamDelegate.modelData.audio.muted = false
                            }
                        }
                        onIconClicked: {
                            if (streamDelegate.modelData.audio)
                                streamDelegate.modelData.audio.muted = !streamDelegate.modelData.audio.muted
                        }
                    }
                }

                PwObjectTracker {
                    objects: [streamDelegate.modelData]
                }
            }
        }
    }

    Text {
        visible: root.streamList.length === 0
        text: "No apps playing audio"
        color: Theme.surfaceVariantText
        font.family: Appearance.fontFamily
        font.pixelSize: 11
    }
}
