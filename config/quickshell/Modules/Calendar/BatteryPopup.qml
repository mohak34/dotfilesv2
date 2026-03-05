import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services

PanelWindow {
    id: batteryWindow
    visible: ShellState.batteryPopupOpen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: ShellState.batteryPopupOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell:battery-popup"

    anchors { top: true; left: true; right: true; bottom: true }
    color: "transparent"

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.closeBatteryPopup()
    }

    Rectangle {
        id: batteryPopup

        x: {
            var triggerX = ShellState.batteryTriggerX
            var triggerWidth = ShellState.batteryTriggerWidth
            if (triggerWidth === 0) {
                return (batteryWindow.width - width) / 2
            }
            var center = triggerX + triggerWidth / 2
            var rawX = center - width / 2
            return Math.max(Appearance.popout.gap, Math.min(rawX, batteryWindow.width - width - Appearance.popout.gap))
        }
        y: batteryWindow.height - Appearance.barHeight - height
        width: 280
        height: 200
        radius: Appearance.popout.radius
        color: Theme.withAlpha(Theme.background, 0.95)

        MouseArea { anchors.fill: parent }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Row {
                spacing: 12

                Text {
                    text: BatteryService.icon
                    color: BatteryService.charging ? Theme.primary : (BatteryService.isLow ? Theme.error : Theme.surfaceText)
                    font.family: Appearance.fontFamily
                    font.pixelSize: 36
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    spacing: 2

                    Text {
                        text: BatteryService.percentage + "%"
                        color: Theme.surfaceText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 24
                        font.weight: Font.Bold
                    }

                    Text {
                        text: {
                            if (BatteryService.charging) return "Charging"
                            if (BatteryService.fullyCharged) return "Fully Charged"
                            if (BatteryService.discharging) return "Discharging"
                            return "On AC Power"
                        }
                        color: Theme.surfaceVariantText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 12
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.outline
            }

            Grid {
                columns: 2
                rows: 2
                columnSpacing: 8
                rowSpacing: 8
                width: parent.width

                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 50
                    radius: 8
                    color: Theme.withAlpha(Theme.surface, 0.5)

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: "Status"
                            color: Theme.surfaceVariantText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                        }

                        Text {
                            text: {
                                if (BatteryService.charging) return "Charging"
                                if (BatteryService.fullyCharged) return "Full"
                                if (BatteryService.discharging) return "Discharging"
                                return "Plugged In"
                            }
                            color: Theme.surfaceText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 50
                    radius: 8
                    color: Theme.withAlpha(Theme.surface, 0.5)

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: "Power"
                            color: Theme.surfaceVariantText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                        }

                        Text {
                            text: {
                                var watts = BatteryService.formatWattage()
                                if (watts) {
                                    return BatteryService.charging ? "+" + watts : watts
                                }
                                return "N/A"
                            }
                            color: Theme.surfaceText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 50
                    radius: 8
                    color: Theme.withAlpha(Theme.surface, 0.5)

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: "Time Remaining"
                            color: Theme.surfaceVariantText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                        }

                        Text {
                            text: {
                                var time = BatteryService.formatTimeRemaining()
                                if (time) {
                                    return time
                                }
                                return "N/A"
                            }
                            color: Theme.surfaceText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 50
                    radius: 8
                    color: Theme.withAlpha(Theme.surface, 0.5)

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: "Health"
                            color: Theme.surfaceVariantText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                        }

                        Text {
                            text: BatteryService.health > 0 ? BatteryService.health + "%" : "N/A"
                            color: BatteryService.health > 0 && BatteryService.health < 80 ? Theme.warning : Theme.surfaceText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }
                    }
                }
            }
        }
    }
}
