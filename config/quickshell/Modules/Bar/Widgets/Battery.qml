import QtQuick
import Quickshell
import qs.Common
import qs.Services

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    readonly property color batteryColor: {
        if (BatteryService.charging || BatteryService.pluggedIn)
            return Theme.primary
        if (BatteryService.isLow)
            return Theme.error
        return Theme.surfaceText
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.spacing.xs

        Text {
            text: BatteryService.icon
            color: root.batteryColor
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
            text: BatteryService.percentage + "%"
            color: root.batteryColor
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSize
            font.weight: Appearance.fontWeight
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color {
                enabled: SettingsService.animationsEnabled
                ColorAnimation { duration: Appearance.anim.quick }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var pos = mapToItem(null, 0, 0)
            ShellState.batteryTriggerX = pos.x
            ShellState.batteryTriggerWidth = root.width
            ShellState.toggleBatteryPopup()
        }
    }
}
