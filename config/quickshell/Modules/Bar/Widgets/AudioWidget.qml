import QtQuick
import Quickshell
import qs.Common
import qs.Services

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    readonly property string micIcon: AudioService.sourceMuted ? "\udb80\udf6d" : "\udb80\udf6c"

    readonly property string volumeIcon: {
        if (AudioService.sinkMuted) return "\udb81\udf5f"
        if (AudioService.sinkVolume <= 0) return "\udb81\udd7f"
        if (AudioService.sinkVolume < 50) return "\udb81\udd80"
        return "\udb81\udd7e"
    }

    readonly property string speakerIcon: {
        var icon = AudioService.sinkIcon
        if (icon === "headset") return "\uf025"
        if (icon === "tv") return "\udb81\udd82"
        return root.volumeIcon
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2

        Text {
            id: micText
            text: root.micIcon
            width: 16
            color: AudioService.sourceMuted ? Theme.error : Theme.surfaceText
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSize
            font.weight: Appearance.fontWeight
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color {
                enabled: SettingsService.animationsEnabled
                ColorAnimation { duration: Appearance.anim.quick }
            }
        }

        Text {
            id: iconText
            text: AudioService.sinkMuted ? "\udb81\udf5f" : root.speakerIcon
            width: 12
            color: AudioService.sinkMuted ? Theme.surfaceVariantText : Theme.surfaceText
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSize
            font.weight: Appearance.fontWeight
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color {
                enabled: SettingsService.animationsEnabled
                ColorAnimation { duration: Appearance.anim.quick }
            }
        }

        Text {
            text: AudioService.sinkVolume + "%"
            color: AudioService.sinkMuted ? Theme.surfaceVariantText : Theme.surfaceText
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
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton) {
                AudioService.cycleSinkOutput()
            } else {
                AudioService.toggleSinkMute()
            }
        }

        onWheel: wheel => {
            var delta = wheel.angleDelta.y > 0 ? 5 : -5
            AudioService.adjustSinkVolume(delta)
        }
    }

    MouseArea {
        x: row.x + micText.x
        y: 0
        width: micText.implicitWidth
        height: root.height
        cursorShape: Qt.PointingHandCursor
        onClicked: AudioService.toggleSourceMute()
    }
}
