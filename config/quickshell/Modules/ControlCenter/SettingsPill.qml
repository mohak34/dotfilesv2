import QtQuick
import qs.Common
import qs.Services

Rectangle {
    id: root

    property string label: ""
    property bool active: false
    signal clicked()

    implicitWidth: pillLabel.implicitWidth + 20
    implicitHeight: 28
    height: 28
    radius: Appearance.rounding.small
    color: active ? Theme.primary : Theme.withAlpha(Theme.surfaceText, 0.08)

    Text {
        id: pillLabel
        text: root.label
        anchors.centerIn: parent
        color: active ? Theme.primaryText : Theme.surfaceVariantText
        font.family: Appearance.fontFamily
        font.pixelSize: 11
        font.weight: active ? Font.Medium : Font.Normal
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
