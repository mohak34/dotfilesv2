import QtQuick
import qs.Common
import qs.Services

Item {
    id: root

    implicitWidth: bellIcon.implicitWidth
    implicitHeight: bellIcon.implicitHeight

    Text {
        id: bellIcon
        text: ShellState.dndEnabled ? "\uDB80\uDC9B" : "\uDB80\uDC9A"
        color: {
            if (ShellState.notificationCenterOpen) return Theme.primary
            if (ShellState.dndEnabled) return Theme.surfaceVariantText
            return Theme.surfaceText
        }
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSize
        font.weight: Appearance.fontWeight

        Behavior on color {
            enabled: SettingsService.animationsEnabled
            ColorAnimation { duration: Appearance.anim.quick }
        }
    }

    Rectangle {
        visible: NotificationService.notifications.length > 0 && !ShellState.dndEnabled
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: -1
        anchors.rightMargin: -2
        width: 5
        height: 5
        radius: 3
        color: Theme.primary
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.toggleNotificationCenter()
    }
}
