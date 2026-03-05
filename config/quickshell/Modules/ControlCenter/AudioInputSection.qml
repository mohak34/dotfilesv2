import QtQuick
import Quickshell.Services.Pipewire
import qs.Common
import qs.Services

Column {
    id: root
    spacing: 6
    width: parent?.width ?? 0

    readonly property var sourceList: {
        var result = []
        var nodes = Pipewire.nodes.values
        for (var i = 0; i < nodes.length; i++) {
            if (nodes[i].audio && !nodes[i].isSink && !nodes[i].isStream)
                result.push(nodes[i])
        }
        return result
    }

    Text {
        text: "Input Devices"
        color: Theme.surfaceVariantText
        font.family: Appearance.fontFamily
        font.pixelSize: 10
        font.weight: Font.Bold
    }

    Column {
        width: parent.width
        spacing: 2

        Repeater {
            model: root.sourceList

            delegate: Rectangle {
                id: deviceDelegate

                required property var modelData
                width: deviceDelegate.parent?.width ?? 0
                height: 36
                radius: 6
                color: deviceMouse.containsMouse
                    ? Theme.withAlpha(Theme.surfaceVariant, 0.3)
                    : "transparent"

                readonly property bool isActive: modelData === AudioService.source

                readonly property string deviceName: {
                    if (!modelData) return ""
                    return AudioService.displayName(modelData)
                }

                readonly property string deviceIcon: {
                    if (!modelData) return "\udb80\udf6c"
                    var name = (modelData.name || "").toLowerCase()
                    if (name.includes("bluez")) return "\udb80\udecb"
                    if (name.includes("usb")) return "\udb80\udecb"
                    return "\udb80\udf6c"
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
                            Pipewire.preferredDefaultAudioSource = deviceDelegate.modelData
                    }
                }
            }
        }
    }

    Text {
        visible: root.sourceList.length === 0
        width: parent.width
        height: 36
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "No input devices"
        color: Theme.surfaceVariantText
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSize
    }
}
