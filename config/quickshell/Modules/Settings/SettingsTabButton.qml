import QtQuick
import qs.Common
import qs.Services

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property bool active: false
    signal clicked()

    width: parent.width
    height: 36
    radius: Appearance.rounding.small
    color: active ? Theme.primary : (tabMouse.containsMouse ? Theme.withAlpha(Theme.surfaceText, 0.08) : "transparent")

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        spacing: 8

        Text {
            text: root.icon
            color: active ? Theme.primaryText : Theme.surfaceVariantText
            font.family: Appearance.fontFamily
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.label
            color: active ? Theme.primaryText : Theme.surfaceVariantText
            font.family: Appearance.fontFamily
            font.pixelSize: 12
            font.weight: active ? Font.Medium : Font.Normal
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: tabMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
