import QtQuick
import Quickshell
import qs.Common
import qs.Services

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    readonly property color iconColor: {
        if (!BluetoothService.available || !BluetoothService.enabled)
            return Theme.surfaceVariantText
        if (BluetoothService.connectedCount > 0)
            return Theme.primary
        return Theme.surfaceText
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.spacing.xs

        Text {
            text: BluetoothService.icon
            color: root.iconColor
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSize + 2
            font.weight: Appearance.fontWeight
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color {
                enabled: SettingsService.animationsEnabled
                ColorAnimation { duration: Appearance.anim.quick }
            }
        }

        Text {
            visible: BluetoothService.connectedCount > 0
            text: BluetoothService.connectedCount.toString()
            color: Theme.primary
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSize
            font.weight: Appearance.fontWeight
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: BluetoothService.toggleBluetooth()
    }
}
