import QtQuick
import qs.Common
import qs.Services

Item {
    id: root
    implicitHeight: settingsCol.implicitHeight

    Column {
        id: settingsCol
        width: parent.width
        spacing: 0

        Row {
            width: parent.width
            bottomPadding: 12

            Text {
                text: "Settings"
                color: Theme.surfaceText
                font.family: Appearance.fontFamily
                font.pixelSize: 16
                font.weight: Font.Bold
                width: parent.width - closeBtn.width
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                id: closeBtn
                width: closeLbl.implicitWidth + 16
                height: closeLbl.implicitHeight + 8
                radius: 6
                color: closeBtnMouse.containsMouse
                    ? Theme.withAlpha(Theme.error, 0.2)
                    : Theme.withAlpha(Theme.surfaceVariant, 0.2)
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: closeLbl
                    anchors.centerIn: parent
                    text: "\u2715"
                    color: closeBtnMouse.containsMouse ? Theme.error : Theme.surfaceVariantText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: closeBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ShellState.closeControlCenter()
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.withAlpha(Theme.outline, 0.15)
        }

        Item { width: parent.width; height: 16 }

        Row {
            width: parent.width
            spacing: 0

            Column {
                id: settingsSidebar
                width: 130
                spacing: 2

                Repeater {
                    model: [
                        { label: "Appearance", icon: "\uf53e" },
                        { label: "Bar",        icon: "\uf0c9" },
                        { label: "Popups",     icon: "\uf2d7" },
                        { label: "Performance",icon: "\uf200" }
                    ]

                    Rectangle {
                        required property var modelData
                        required property int index

                        width: settingsSidebar.width
                        height: 34
                        radius: Appearance.rounding.small
                        color: settingsTab === index
                            ? Theme.primary
                            : (sideTabMouse.containsMouse ? Theme.withAlpha(Theme.surfaceText, 0.08) : "transparent")

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            spacing: 8

                            Text {
                                text: modelData.icon
                                color: settingsTab === index ? Theme.primaryText : Theme.surfaceVariantText
                                font.family: Appearance.fontFamily
                                font.pixelSize: 13
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.label
                                color: settingsTab === index ? Theme.primaryText : Theme.surfaceVariantText
                                font.family: Appearance.fontFamily
                                font.pixelSize: 11
                                font.weight: settingsTab === index ? Font.Medium : Font.Normal
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: sideTabMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: settingsTab = index
                        }
                    }
                }
            }

            Rectangle {
                width: 1
                height: settingsContent.implicitHeight
                color: Theme.withAlpha(Theme.outline, 0.15)
                anchors.top: parent.top
                x: settingsSidebar.width + 8
            }

            Item { width: 16; height: 1 }

            Item {
                id: settingsContent
                width: parent.width - settingsSidebar.width - 16
                implicitHeight: settingsLoader.item ? settingsLoader.item.implicitHeight : 0
                height: implicitHeight

                Loader {
                    id: settingsLoader
                    width: parent.width
                    sourceComponent: {
                        if (settingsTab === 0) return appearanceComp
                        if (settingsTab === 1) return barComp
                        if (settingsTab === 2) return popupsComp
                        return performanceComp
                    }
                }

                Component {
                    id: appearanceComp
                    SettingsAppearance {}
                }

                Component {
                    id: barComp
                    SettingsBar {}
                }

                Component {
                    id: popupsComp
                    SettingsPopups {}
                }

                Component {
                    id: performanceComp
                    SettingsPerformance {}
                }
            }
        }
    }

    property int settingsTab: 0
}
