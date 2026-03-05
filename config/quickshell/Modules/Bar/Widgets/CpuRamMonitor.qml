import QtQuick
import Quickshell
import qs.Common
import qs.Services

Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    readonly property color cpuColor: {
        if (SystemMetricsService.cpuPercent > 80) return Theme.error
        if (SystemMetricsService.cpuPercent > 60) return Theme.warning
        return Theme.surfaceText
    }

    readonly property color ramColor: {
        if (SystemMetricsService.ramPercent > 90) return Theme.error
        if (SystemMetricsService.ramPercent > 75) return Theme.warning
        return Theme.surfaceText
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.spacing.m

        Row {
            spacing: Appearance.spacing.xs
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: "\udb80\udf5b"
                color: root.cpuColor
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSize + 2
                font.weight: Appearance.fontWeight
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color {
                    enabled: SettingsService.animationsEnabled
                    ColorAnimation { duration: Appearance.anim.quick }
                }
            }

            Text {
                text: SystemMetricsService.cpuPercent > 0 ? SystemMetricsService.cpuPercent + "%" : "--%"
                color: root.cpuColor
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

        Row {
            spacing: Appearance.spacing.xs
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: "\udb81\ude1a"
                color: root.ramColor
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSize + 2
                font.weight: Appearance.fontWeight
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color {
                    enabled: SettingsService.animationsEnabled
                    ColorAnimation { duration: Appearance.anim.quick }
                }
            }

            Text {
                text: SystemMetricsService.ramPercent > 0 ? SystemMetricsService.ramPercent + "%" : "--%"
                color: root.ramColor
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
    }
}
