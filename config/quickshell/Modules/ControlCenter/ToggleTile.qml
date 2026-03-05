import QtQuick
import qs.Common
import qs.Services

Item {
    id: root

    required property string label
    required property string sublabel
    required property string icon
    required property bool active
    property bool hasDetail: false

    signal toggled()
    signal detailRequested()

    implicitHeight: 60
    implicitWidth: 100

    property bool _hovered: false

    Rectangle {
        anchors.fill: parent
        radius: Appearance.popout.radius
        color: {
            if (root.active) {
                return root._hovered
                    ? Theme.withAlpha(Theme.primary, 0.25)
                    : Theme.withAlpha(Theme.primary, 0.15)
            }
            return root._hovered
                ? Theme.surfaceHover
                : Theme.withAlpha(Theme.surface, 0.3)
        }
        border.width: root.active ? 1 : 0
        border.color: Theme.withAlpha(Theme.primary, 0.3)

        Behavior on color {
            enabled: SettingsService.animationsEnabled
            ColorAnimation { duration: Appearance.anim.quick }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root._hovered = true
            onExited: root._hovered = false
            cursorShape: Qt.PointingHandCursor
        }

        Row {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            Rectangle {
                id: iconBtn
                width: 44; height: 44
                radius: 12
                anchors.verticalCenter: parent.verticalCenter
                color: root.active
                    ? Theme.primary
                    : Theme.withAlpha(Theme.surfaceVariant, 0.4)

                Behavior on color {
                    enabled: SettingsService.animationsEnabled
                    ColorAnimation { duration: Appearance.anim.quick }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.icon
                    color: root.active ? Theme.primaryText : Theme.surfaceText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 18
                    font.weight: Appearance.fontWeight

                    Behavior on color {
                        enabled: SettingsService.animationsEnabled
                        ColorAnimation { duration: Appearance.anim.quick }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggled()
                }
            }

            Item {
                width: parent.width - iconBtn.width - parent.spacing
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    spacing: 2

                    Text {
                        text: root.label
                        color: Theme.surfaceText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Text {
                        text: root.sublabel
                        color: Theme.surfaceVariantText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        width: parent.width
                        visible: text !== ""
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: root.hasDetail ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (root.hasDetail) root.detailRequested()
                    }
                }
            }
        }
    }
}
