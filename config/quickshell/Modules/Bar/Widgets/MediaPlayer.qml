import QtQuick
import qs.Common
import qs.Services

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    readonly property bool hasMpris: typeof MprisController !== "undefined"
    readonly property var activePlayer: hasMpris ? MprisController.activePlayer : null
    readonly property bool hasPlayer: hasMpris && activePlayer !== null && activePlayer !== undefined

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.spacing.xs

        Text {
            text: "\uf001"
            color: Theme.surfaceText
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSize
            anchors.verticalCenter: parent.verticalCenter
            visible: root.hasPlayer
        }

        Text {
            text: {
                if (!root.hasPlayer || !activePlayer || !activePlayer.trackTitle) return ""
                var title = activePlayer.trackTitle
                if (title.length > 20) title = title.substring(0, 17) + "..."
                return title
            }
            color: Theme.surfaceText
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSize
            anchors.verticalCenter: parent.verticalCenter
            visible: root.hasPlayer && activePlayer && activePlayer.trackTitle
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: root.hasPlayer
        onClicked: {
            if (root.hasPlayer && activePlayer && activePlayer.canTogglePlaying) {
                activePlayer.togglePlaying()
            }
        }
    }
}
