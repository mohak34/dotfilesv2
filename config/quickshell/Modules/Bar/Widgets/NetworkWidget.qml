import QtQuick
import Quickshell
import qs.Common
import qs.Services

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.spacing.xs

        Text {
            text: NetworkService.networkIcon
            color: NetworkService.connected ? Theme.surfaceText : Theme.surfaceVariantText
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
            var pos = root.mapToItem(null, 0, 0)
            ShellState.ccTriggerX = pos.x
            ShellState.ccTriggerWidth = root.width
            if (ShellState.controlCenterOpen && ShellState.activeTab === "cc") {
                ShellState.closeControlCenter()
            } else {
                ShellState.openTab("cc")
            }
        }
    }
}
