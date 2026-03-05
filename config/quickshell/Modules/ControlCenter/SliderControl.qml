import QtQuick
import qs.Common
import qs.Services

Item {
    id: root

    required property real value
    property real minimum: 0
    property real maximum: 100
    property string icon: ""
    property bool muted: false

    signal sliderMoved(real newValue)
    signal iconClicked()

    implicitHeight: 32
    implicitWidth: 200

    Text {
        id: iconText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon
        color: root.muted ? Theme.error : Theme.surfaceText
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSize + 4
        font.weight: Appearance.fontWeight
        width: 22
        horizontalAlignment: Text.AlignHCenter

        Behavior on color {
            enabled: SettingsService.animationsEnabled
            ColorAnimation { duration: Appearance.anim.quick }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.iconClicked()
        }
    }

    Text {
        id: percentText
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: Math.round(root.value) + "%"
        color: root.muted ? Theme.surfaceVariantText : Theme.surfaceText
        font.family: Appearance.fontFamily
        font.pixelSize: 11
        font.weight: Font.Bold
        width: 32
        horizontalAlignment: Text.AlignRight
    }

    Item {
        id: trackContainer
        anchors.left: iconText.right
        anchors.right: percentText.left
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        height: 6

        Rectangle {
            anchors.fill: parent
            radius: 3
            color: Theme.withAlpha(Theme.surfaceVariant, 0.3)
        }

        Rectangle {
            width: {
                var range = root.maximum - root.minimum
                if (range <= 0) return 0
                return parent.width * Math.max(0, Math.min(1, (root.value - root.minimum) / range))
            }
            height: parent.height
            radius: 3
            color: root.muted ? Theme.error : Theme.primary

            Behavior on color {
                enabled: SettingsService.animationsEnabled
                ColorAnimation { duration: Appearance.anim.quick }
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.topMargin: -13
            anchors.bottomMargin: -13
            cursorShape: Qt.PointingHandCursor

            onPressed: mouse => _updateValue(mouse.x)
            onPositionChanged: mouse => {
                if (pressed) _updateValue(mouse.x)
            }

            function _updateValue(mouseX) {
                var ratio = Math.max(0, Math.min(1, mouseX / trackContainer.width))
                var newVal = root.minimum + ratio * (root.maximum - root.minimum)
                root.sliderMoved(Math.round(newVal))
            }
        }
    }
}
