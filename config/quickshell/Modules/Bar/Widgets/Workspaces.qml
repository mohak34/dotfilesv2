import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Common
import qs.Services

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    property var persistentIds: [1, 2, 3, 4, 5]

    property var workspaceIds: {
        var ids = persistentIds.slice()
        var wsValues = Hyprland.workspaces.values
        for (var i = 0; i < wsValues.length; i++) {
            var wsId = wsValues[i].id
            if (wsId > 0 && ids.indexOf(wsId) === -1)
                ids.push(wsId)
        }
        var focusedId = Hyprland.focusedWorkspace?.id ?? 0
        if (focusedId > 0 && ids.indexOf(focusedId) === -1)
            ids.push(focusedId)
        return ids.sort((a, b) => a - b)
    }

    RowLayout {
        id: row
        spacing: 2

        Repeater {
            model: root.workspaceIds

            delegate: Rectangle {
                required property int modelData

                property int wsId: modelData
                property var ws: Hyprland.workspaces.values.find(w => w.id === wsId) ?? null
                property bool isActive: Hyprland.focusedWorkspace?.id === wsId
                property bool isOccupied: ws !== null

                implicitWidth: wsLabel.implicitWidth + 12
                implicitHeight: wsLabel.implicitHeight + 2
                radius: Appearance.rounding.small
                color: hoverArea.containsMouse
                    ? Theme.withAlpha(Theme.surface, 0.5)
                    : "transparent"

                Behavior on color {
                    enabled: SettingsService.animationsEnabled
                    ColorAnimation { duration: Appearance.anim.quick }
                }

                Text {
                    id: wsLabel
                    anchors.centerIn: parent
                    text: parent.wsId
                    color: parent.isActive
                        ? Theme.primary
                        : parent.isOccupied
                            ? Theme.surfaceText
                            : Theme.surfaceVariantText
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize
                    font.weight: Appearance.fontWeight

                    Behavior on color {
                        enabled: SettingsService.animationsEnabled
                        ColorAnimation { duration: Appearance.anim.quick }
                    }
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + parent.wsId)
                }
            }
        }
    }
}
