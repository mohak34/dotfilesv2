import QtQuick
import qs.Common
import qs.Services

Item {
    id: root

    required property string icon
    required property real value
    property bool muted: false

    implicitWidth: 340
    implicitHeight: 40

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Theme.withAlpha(Theme.surface, 0.95)
        border.width: 1
        border.color: Theme.withAlpha(Theme.outline, 0.1)

        Row {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Text {
                text: root.icon
                color: root.muted ? Theme.error : Theme.surfaceText
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSize + 4
                font.weight: Appearance.fontWeight
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 20 - 40 - 20
                height: 6

                Rectangle {
                    anchors.fill: parent
                    radius: 3
                    color: Theme.withAlpha(Theme.surfaceVariant, 0.3)
                }

                Rectangle {
                    width: parent.width * Math.min(1, Math.max(0, root.value / 100))
                    height: parent.height
                    radius: 3
                    color: root.muted ? Theme.error : Theme.primary

                    Behavior on width {
                        enabled: SettingsService.animationsEnabled
                        NumberAnimation { duration: 100 }
                    }
                }
            }

            Text {
                text: Math.round(root.value) + "%"
                color: root.muted ? Theme.error : Theme.surfaceText
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSize
                font.weight: Appearance.fontWeight
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
