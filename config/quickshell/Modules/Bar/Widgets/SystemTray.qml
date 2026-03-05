import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Common
import qs.Services

Item {
    id: root
    implicitWidth: trayRow.implicitWidth
    implicitHeight: trayRow.implicitHeight

    readonly property bool hasItems: SystemTray.items.values.length > 0

    readonly property var hiddenTrayIds: {
        var envValue = Quickshell.env("DMS_HIDE_TRAYIDS") || ""
        return envValue ? envValue.split(",").map(id => id.trim().toLowerCase()) : []
    }

    readonly property var visibleItems: {
        var items = SystemTray.items.values
        if (!hiddenTrayIds.length) return items
        return items.filter(item => {
            var itemId = item?.id || ""
            return !hiddenTrayIds.includes(itemId.toLowerCase())
        })
    }

    Row {
        id: trayRow
        anchors.centerIn: parent
	spacing: 0

        Repeater {
            model: root.visibleItems

            delegate: Item {
                id: trayDelegate
                required property var modelData

                width: Appearance.barHeight - 4
                height: Appearance.barHeight - 4
                anchors.verticalCenter: parent?.verticalCenter ?? undefined

                Rectangle {
                    id: iconBg
                    anchors.fill: parent
                    radius: Appearance.rounding.small
                    color: trayMouse.containsMouse
                        ? Theme.withAlpha(Theme.surface, 0.5)
                        : "transparent"

                    Behavior on color {
                        enabled: SettingsService.animationsEnabled
                        ColorAnimation { duration: Appearance.anim.quick }
                    }
                }

                IconImage {
                    id: trayIcon
                    anchors.centerIn: parent
                    implicitSize: Appearance.fontSize + 4
                    source: modelData.icon ?? ""
                    asynchronous: true
                }

                Text {
                    anchors.centerIn: parent
                    visible: trayIcon.status !== Image.Ready
                    text: {
                        var itemId = modelData?.id || ""
                        return itemId ? itemId.charAt(0).toUpperCase() : "?"
                    }
                    font.family: Appearance.fontFamily
                    font.pixelSize: 10
                    font.weight: Appearance.fontWeight
                    color: Theme.surfaceVariantText
                }

                MouseArea {
                    id: trayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onClicked: mouse => {
                        var parentWin = QsWindow.window
                        if (mouse.button === Qt.RightButton) {
                            if (modelData.hasMenu) {
                                var gp = trayMouse.mapToItem(null, mouse.x, mouse.y)
                                modelData.display(parentWin, gp.x, gp.y)
                            }
                        } else if (mouse.button === Qt.MiddleButton) {
                            modelData.secondaryActivate()
                        } else {
                            if (modelData.onlyMenu && modelData.hasMenu) {
                                var gp2 = trayMouse.mapToItem(null, mouse.x, mouse.y)
                                modelData.display(parentWin, gp2.x, gp2.y)
                            } else {
                                modelData.activate()
                            }
                        }
                    }
                }
            }
        }
    }
}
