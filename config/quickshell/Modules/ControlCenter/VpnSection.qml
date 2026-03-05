import QtQuick
import qs.Common
import qs.Services

Column {
    id: root
    spacing: 8
    visible: NetworkService.vpnConnections.length > 0

    Text {
        text: "VPN"
        color: Theme.surfaceText
        font.family: Appearance.fontFamily
        font.pixelSize: 13
        font.weight: Font.Bold
    }

    Rectangle {
        width: parent.width
        implicitHeight: vpnColumn.implicitHeight + 16
        radius: 12
        color: Theme.withAlpha(Theme.surface, 0.3)

        Column {
            id: vpnColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            y: 8
            spacing: 4

            Repeater {
                model: NetworkService.vpnConnections

                delegate: Rectangle {
                    id: vpnDelegate

                    required property var modelData
                    required property int index
                    width: vpnDelegate.parent?.width ?? 0
                    height: 36
                    radius: 6
                    color: vpnMouse.containsMouse
                        ? Theme.withAlpha(Theme.surfaceVariant, 0.3)
                        : "transparent"

                    readonly property bool isActive: modelData.active

                    Text {
                        id: vpnIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\uDB81\uDD82"
                        color: vpnDelegate.isActive ? Theme.primary : Theme.surfaceVariantText
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSize + 2
                    }

                    Text {
                        anchors.left: vpnIcon.right
                        anchors.leftMargin: 8
                        anchors.right: vpnActionBtn.left
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.name
                        color: vpnDelegate.isActive ? Theme.primary : Theme.surfaceText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 11
                        font.weight: vpnDelegate.isActive ? Font.Bold : Font.Normal
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        id: vpnActionBtn
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        width: vpnActionLabel.implicitWidth + 12
                        height: vpnActionLabel.implicitHeight + 6
                        radius: 4
                        color: vpnActionMouse.containsMouse
                            ? Theme.withAlpha(vpnDelegate.isActive ? Theme.error : Theme.primary, 0.2)
                            : Theme.withAlpha(Theme.surfaceVariant, 0.2)

                        Text {
                            id: vpnActionLabel
                            anchors.centerIn: parent
                            text: vpnDelegate.isActive ? "Disconnect" : "Connect"
                            color: vpnActionMouse.containsMouse
                                ? (vpnDelegate.isActive ? Theme.error : Theme.primary)
                                : Theme.surfaceText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: vpnActionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (vpnDelegate.isActive)
                                    NetworkService.disconnectVpn(modelData.name)
                                else
                                    NetworkService.connectVpn(modelData.name)
                            }
                        }
                    }

                    MouseArea {
                        id: vpnMouse
                        anchors.fill: parent
                        anchors.rightMargin: vpnActionBtn.width + 8
                        hoverEnabled: true
                    }
                }
            }
        }
    }
}
