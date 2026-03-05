import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Modules.Settings

PanelWindow {
    id: settingsWindow
    visible: ShellState.settingsOpen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: ShellState.settingsOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell:settings"

    anchors { top: true; left: true; right: true; bottom: true }
    color: "transparent"

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.closeSettings()
    }

    Rectangle {
        id: settingsContainer

        readonly property int sidebarWidth: 160
        readonly property int titlebarHeight: 44

        x: Math.round((settingsWindow.width - width) / 2)
        y: Math.round((settingsWindow.height - height) / 2)
        width: 680
        height: 480
        radius: Appearance.rounding.large
        color: Theme.background

        layer.enabled: true

        MouseArea { anchors.fill: parent }

        Rectangle {
            id: sidebar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: settingsContainer.sidebarWidth
            color: Theme.surfaceVariant
            radius: Appearance.rounding.large

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: Appearance.rounding.large
                color: parent.color
            }

            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2

                Item { width: parent.width; height: 12 }

                Text {
                    text: "Settings"
                    color: Theme.surfaceText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    leftPadding: 8
                    bottomPadding: 8
                }

                SettingsTabButton {
                    icon: "\uf53e"
                    label: "Appearance"
                    active: settingsTab === 0
                    onClicked: settingsTab = 0
                }

                SettingsTabButton {
                    icon: "\uf0c9"
                    label: "Bar"
                    active: settingsTab === 1
                    onClicked: settingsTab = 1
                }

                SettingsTabButton {
                    icon: "\uf2d7"
                    label: "Popups"
                    active: settingsTab === 2
                    onClicked: settingsTab = 2
                }

                SettingsTabButton {
                    icon: "\uf200"
                    label: "Performance"
                    active: settingsTab === 3
                    onClicked: settingsTab = 3
                }
            }
        }

        Item {
            id: contentArea
            anchors.top: parent.top
            anchors.left: sidebar.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            Item {
                id: titlebar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: settingsContainer.titlebarHeight

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (settingsTab === 0) return "Appearance"
                        if (settingsTab === 1) return "Bar"
                        if (settingsTab === 2) return "Popups"
                        return "Performance"
                    }
                    color: Theme.surfaceText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 16
                    font.weight: Font.Bold
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    height: 24
                    radius: 12
                    color: closeMouse.containsMouse ? Theme.surfaceVariant : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "\uf00d"
                        color: Theme.surfaceVariantText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ShellState.closeSettings()
                    }
                }
            }

            Rectangle {
                anchors.top: titlebar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Theme.outline
                opacity: 0.3
            }

            Item {
                anchors.top: titlebar.bottom
                anchors.topMargin: 1
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                Loader {
                    anchors.fill: parent
                    anchors.margins: 16
                    sourceComponent: {
                        if (settingsTab === 0) return appearanceComp
                        if (settingsTab === 1) return barComp
                        if (settingsTab === 2) return popupsComp
                        return performanceComp
                    }
                }

                Component {
                    id: appearanceComp
                    AppearanceSettings {}
                }

                Component {
                    id: barComp
                    BarSettings {}
                }

                Component {
                    id: popupsComp
                    PopupSettings {}
                }

                Component {
                    id: performanceComp
                    PerformanceSettings {}
                }
            }
        }
    }

    property int settingsTab: 0
}
