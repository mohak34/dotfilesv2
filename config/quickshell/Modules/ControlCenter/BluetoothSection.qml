import QtQuick
import qs.Common
import qs.Services

Column {
    id: root
    spacing: 6
    width: parent?.width ?? 0

    Row {
        width: parent.width
        spacing: 6

        Rectangle {
            width: scanBtLabel.implicitWidth + 16
            height: scanBtLabel.implicitHeight + 8
            radius: 6
            color: scanBtMouse.containsMouse
                ? Theme.withAlpha(Theme.primary, 0.2)
                : Theme.withAlpha(Theme.surfaceVariant, 0.2)

            Text {
                id: scanBtLabel
                anchors.centerIn: parent
                text: BluetoothService.discovering ? "Scanning..." : "Scan"
                color: Theme.surfaceText
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
            }

            MouseArea {
                id: scanBtMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: BluetoothService.discovering ? Qt.ArrowCursor : Qt.PointingHandCursor
                enabled: !BluetoothService.discovering
                onClicked: BluetoothService.startScan()
            }
        }

        Rectangle {
            visible: BluetoothService.discovering
            width: stopScanLabel.implicitWidth + 16
            height: stopScanLabel.implicitHeight + 8
            radius: 6
            color: stopScanMouse.containsMouse
                ? Theme.withAlpha(Theme.error, 0.2)
                : Theme.withAlpha(Theme.surfaceVariant, 0.2)

            Text {
                id: stopScanLabel
                anchors.centerIn: parent
                text: "Stop"
                color: stopScanMouse.containsMouse ? Theme.error : Theme.surfaceText
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
            }

            MouseArea {
                id: stopScanMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: BluetoothService.stopScan()
            }
        }
    }

    Text {
        visible: BluetoothService.connectedDevices.length > 0
        text: "Connected"
        color: Theme.surfaceVariantText
        font.family: Appearance.fontFamily
        font.pixelSize: 10
        font.weight: Font.Bold
    }

    Column {
        width: parent.width
        spacing: 2
        visible: BluetoothService.connectedDevices.length > 0

        Repeater {
            model: BluetoothService.connectedDevices

            delegate: Rectangle {
                id: connDelegate
                required property var modelData
                width: connDelegate.parent?.width ?? 0
                height: 36
                radius: 6
                color: connMouse.containsMouse
                    ? Theme.withAlpha(Theme.surfaceVariant, 0.3)
                    : "transparent"

                Text {
                    id: connIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: BluetoothService.getDeviceIcon(connDelegate.modelData)
                    color: Theme.primary
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize + 2
                }

                Text {
                    anchors.left: connIcon.right
                    anchors.leftMargin: 8
                    anchors.right: connAction.left
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: connDelegate.modelData.name || "Unknown"
                    color: Theme.primary
                    font.family: Appearance.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                Rectangle {
                    id: connAction
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    width: connActionLabel.implicitWidth + 12
                    height: connActionLabel.implicitHeight + 6
                    radius: 4
                    color: connActionMouse.containsMouse
                        ? Theme.withAlpha(Theme.error, 0.2)
                        : Theme.withAlpha(Theme.surfaceVariant, 0.2)

                    Text {
                        id: connActionLabel
                        anchors.centerIn: parent
                        text: "Disconnect"
                        color: connActionMouse.containsMouse ? Theme.error : Theme.surfaceText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: connActionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: BluetoothService.disconnectDevice(connDelegate.modelData)
                    }
                }

                MouseArea {
                    id: connMouse
                    anchors.fill: parent
                    anchors.rightMargin: connAction.width + 8
                    hoverEnabled: true
                }
            }
        }
    }

    Text {
        visible: BluetoothService.pairedDevices.length > BluetoothService.connectedDevices.length
        text: "Paired"
        color: Theme.surfaceVariantText
        font.family: Appearance.fontFamily
        font.pixelSize: 10
        font.weight: Font.Bold
    }

    Column {
        width: parent.width
        spacing: 2

        Repeater {
            model: {
                var paired = BluetoothService.pairedDevices
                var connected = BluetoothService.connectedDevices
                return paired.filter(d => !d.connected)
            }

            delegate: Rectangle {
                id: pairedDelegate
                required property var modelData
                width: pairedDelegate.parent?.width ?? 0
                height: 36
                radius: 6
                color: pairedMouse.containsMouse
                    ? Theme.withAlpha(Theme.surfaceVariant, 0.3)
                    : "transparent"

                Text {
                    id: pairedIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: BluetoothService.getDeviceIcon(pairedDelegate.modelData)
                    color: Theme.surfaceText
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize + 2
                }

                Text {
                    anchors.left: pairedIcon.right
                    anchors.leftMargin: 8
                    anchors.right: pairedAction.left
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: pairedDelegate.modelData.name || "Unknown"
                    color: Theme.surfaceText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }

                Rectangle {
                    id: pairedAction
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    width: pairedActionLabel.implicitWidth + 12
                    height: pairedActionLabel.implicitHeight + 6
                    radius: 4
                    color: pairedActionMouse.containsMouse
                        ? Theme.withAlpha(Theme.primary, 0.2)
                        : Theme.withAlpha(Theme.surfaceVariant, 0.2)

                    Text {
                        id: pairedActionLabel
                        anchors.centerIn: parent
                        text: "Connect"
                        color: pairedActionMouse.containsMouse ? Theme.primary : Theme.surfaceText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: pairedActionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: BluetoothService.connectDevice(pairedDelegate.modelData)
                    }
                }

                MouseArea {
                    id: pairedMouse
                    anchors.fill: parent
                    anchors.rightMargin: pairedAction.width + 8
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: BluetoothService.connectDevice(pairedDelegate.modelData)
                }
            }
        }
    }

    Text {
        visible: BluetoothService.pairedDevices.length === 0 && !BluetoothService.discovering
        text: "No paired devices"
        color: Theme.surfaceVariantText
        font.family: Appearance.fontFamily
        font.pixelSize: 11
    }
}
