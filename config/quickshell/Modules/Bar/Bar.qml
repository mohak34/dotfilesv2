import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Modules.Bar.Widgets

Scope {
    id: root
    required property var screen

    PanelWindow {
        id: barWindow
        visible: ShellState.barVisible

        screen: root.screen
        implicitHeight: Appearance.barHeight

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusiveZone: Appearance.barHeight
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors {
            bottom: true
            left: true
            right: true
        }

        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Theme.withAlpha(Theme.background, 0.85)

            Row {
                id: leftSection
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 6
                spacing: Appearance.spacing.xs

                Workspaces {}
            }

            Item {
                id: centerSection
                anchors.centerIn: parent
                implicitWidth: centerRow.implicitWidth
                implicitHeight: centerRow.implicitHeight
                width: implicitWidth
                height: implicitHeight

                Row {
                    id: centerRow
                    spacing: Appearance.spacing.m

                    Clock { id: clockWidget }
                    NotificationBell { id: bellContent }
                }
            }

            Row {
                id: rightSection
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 6
                spacing: Appearance.pill.spacing

                Rectangle {
                    visible: trayContent.hasItems
                    height: barWindow.implicitHeight - Appearance.pill.verticalMargin * 2
                    width: trayContent.implicitWidth 
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Appearance.pill.radius
                    color: Theme.withAlpha(Theme.surfaceText, 0.12)

                    SystemTray {
                        id: trayContent
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    height: barWindow.implicitHeight - Appearance.pill.verticalMargin * 2
                    width: connectivityContent.implicitWidth + Appearance.pill.horizontalPadding * 2
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Appearance.pill.radius
                    color: Theme.withAlpha(Theme.surfaceText, 0.12)

                    Row {
                        id: connectivityContent
                        anchors.centerIn: parent
                        spacing: Appearance.spacing.m

                        NetworkWidget {}
                        AudioWidget {}
                    }
                }

                Rectangle {
                    visible: BatteryService.available
                    height: barWindow.implicitHeight - Appearance.pill.verticalMargin * 2
                    width: batteryContent.implicitWidth + Appearance.pill.horizontalPadding * 2
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Appearance.pill.radius
                    color: Theme.withAlpha(Theme.surfaceText, 0.12)

                    Battery {
                        id: batteryContent
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }
}
