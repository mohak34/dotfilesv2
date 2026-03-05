import QtQuick
import Qt.labs.folderlistmodel
import qs.Common
import qs.Services

Item {
    id: root

    readonly property int cellGap: 8
    readonly property int gridCols: 6
    readonly property int cellSize: Math.floor((Appearance.popout.ccWidth - 2 * Appearance.popout.contentMargin - (gridCols - 1) * cellGap) / gridCols)
    readonly property int gridWidth: gridCols * cellSize + (gridCols - 1) * cellGap
    readonly property int gridViewportHeight: 3 * cellSize + 2 * cellGap + 12

    readonly property var presetNames: ["Tokyo Night", "Rosé Pine", "Nord", "Gruvbox", "Catppuccin Mocha"]

    implicitWidth: gridWidth
    implicitHeight: content.implicitHeight

    FolderListModel {
        id: folderModel
        folder: Qt.resolvedUrl("file://" + WallpaperService.wallpaperDir)
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        showDirs: false
        sortField: FolderListModel.Name
    }

    Column {
        id: content
        width: parent.width
        spacing: 10

        Item {
            id: themingRow
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Theming"
                color: Theme.surfaceVariantText
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Rectangle {
                    width: onPillLabel.implicitWidth + 16
                    height: 24
                    radius: 8
                    color: WallpaperService.wallpaperThemingEnabled
                        ? Theme.primary
                        : Theme.withAlpha(Theme.surfaceVariant, 0.4)

                    Behavior on color {
                        enabled: SettingsService.animationsEnabled
                        ColorAnimation { duration: Appearance.anim.quick }
                    }

                    Text {
                        id: onPillLabel
                        anchors.centerIn: parent
                        text: "On"
                        color: WallpaperService.wallpaperThemingEnabled ? Theme.primaryText : Theme.surfaceVariantText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold

                        Behavior on color {
                            enabled: SettingsService.animationsEnabled
                            ColorAnimation { duration: Appearance.anim.quick }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WallpaperService.wallpaperThemingEnabled = true
                    }
                }

                Rectangle {
                    width: offPillLabel.implicitWidth + 16
                    height: 24
                    radius: 8
                    color: !WallpaperService.wallpaperThemingEnabled
                        ? Theme.primary
                        : Theme.withAlpha(Theme.surfaceVariant, 0.4)

                    Behavior on color {
                        enabled: SettingsService.animationsEnabled
                        ColorAnimation { duration: Appearance.anim.quick }
                    }

                    Text {
                        id: offPillLabel
                        anchors.centerIn: parent
                        text: "Off"
                        color: !WallpaperService.wallpaperThemingEnabled ? Theme.primaryText : Theme.surfaceVariantText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold

                        Behavior on color {
                            enabled: SettingsService.animationsEnabled
                            ColorAnimation { duration: Appearance.anim.quick }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WallpaperService.wallpaperThemingEnabled = false
                    }
                }
            }
        }

        Item {
            id: themeSourceRow
            width: parent.width
            height: 24
            visible: WallpaperService.wallpaperThemingEnabled

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Theme Source"
                color: Theme.surfaceVariantText
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Rectangle {
                    width: wallpaperPillLabel.implicitWidth + 16
                    height: 24
                    radius: 8
                    color: WallpaperService.useMatugen
                        ? Theme.primary
                        : Theme.withAlpha(Theme.surfaceVariant, 0.4)

                    Behavior on color {
                        enabled: SettingsService.animationsEnabled
                        ColorAnimation { duration: Appearance.anim.quick }
                    }

                    Text {
                        id: wallpaperPillLabel
                        anchors.centerIn: parent
                        text: "Wallpaper"
                        color: WallpaperService.useMatugen ? Theme.primaryText : Theme.surfaceVariantText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold

                        Behavior on color {
                            enabled: SettingsService.animationsEnabled
                            ColorAnimation { duration: Appearance.anim.quick }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WallpaperService.useMatugen = true
                    }
                }

                Rectangle {
                    width: presetPillLabel.implicitWidth + 16
                    height: 24
                    radius: 8
                    color: !WallpaperService.useMatugen
                        ? Theme.primary
                        : Theme.withAlpha(Theme.surfaceVariant, 0.4)

                    Behavior on color {
                        enabled: SettingsService.animationsEnabled
                        ColorAnimation { duration: Appearance.anim.quick }
                    }

                    Text {
                        id: presetPillLabel
                        anchors.centerIn: parent
                        text: "Preset"
                        color: !WallpaperService.useMatugen ? Theme.primaryText : Theme.surfaceVariantText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold

                        Behavior on color {
                            enabled: SettingsService.animationsEnabled
                            ColorAnimation { duration: Appearance.anim.quick }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WallpaperService.useMatugen = false
                    }
                }
            }
        }

        Item {
            id: schemeRow
            width: parent.width
            height: 24
            visible: WallpaperService.useMatugen && WallpaperService.wallpaperThemingEnabled

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Scheme"
                color: Theme.surfaceVariantText
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                readonly property var schemes: ["tonal-spot", "monochrome", "neutral", "vibrant"]

                Repeater {
                    model: parent.schemes

                    delegate: Rectangle {
                        required property string modelData

                        width: schemeLabel.implicitWidth + 10
                        height: 22
                        radius: 6
                        color: WallpaperService.colorScheme === modelData
                            ? Theme.primary
                            : Theme.withAlpha(Theme.surfaceVariant, 0.4)

                        Behavior on color {
                            enabled: SettingsService.animationsEnabled
                            ColorAnimation { duration: Appearance.anim.quick }
                        }

                        Text {
                            id: schemeLabel
                            anchors.centerIn: parent
                            text: modelData === "tonal-spot" ? "Tonal" : (modelData.charAt(0).toUpperCase() + modelData.slice(1))
                            color: WallpaperService.colorScheme === modelData ? Theme.primaryText : Theme.surfaceVariantText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold

                            Behavior on color {
                                enabled: SettingsService.animationsEnabled
                                ColorAnimation { duration: Appearance.anim.quick }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: WallpaperService.colorScheme = modelData
                        }
                    }
                }
            }
        }

        Flow {
            id: presetRow
            visible: !WallpaperService.useMatugen && WallpaperService.wallpaperThemingEnabled
            width: parent.width
            spacing: 6

            Repeater {
                model: root.presetNames

                delegate: Rectangle {
                    id: presetBtn
                    required property string modelData
                    required property int index

                    readonly property bool isActive: WallpaperService.currentPreset === modelData

                    width: presetBtnLabel.implicitWidth + 16
                    height: 26
                    radius: 8
                    color: isActive
                        ? Theme.primary
                        : (presetBtnMouse.containsMouse
                            ? Theme.withAlpha(Theme.surfaceVariant, 0.5)
                            : Theme.withAlpha(Theme.surfaceVariant, 0.25))

                    Behavior on color {
                        enabled: SettingsService.animationsEnabled
                        ColorAnimation { duration: Appearance.anim.quick }
                    }

                    Text {
                        id: presetBtnLabel
                        anchors.centerIn: parent
                        text: presetBtn.modelData
                        color: presetBtn.isActive ? Theme.primaryText : Theme.surfaceText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold

                        Behavior on color {
                            enabled: SettingsService.animationsEnabled
                            ColorAnimation { duration: Appearance.anim.quick }
                        }
                    }

                    MouseArea {
                        id: presetBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WallpaperService.applyPreset(presetBtn.modelData)
                    }
                }
            }
        }

        Rectangle {
            id: divider
            width: parent.width
            height: 1
            color: Theme.withAlpha(Theme.outline, 0.15)
        }

        Item {
            width: parent.width
            height: root.gridViewportHeight

            Flickable {
                id: gridFlick
                anchors.fill: parent
                contentWidth: root.gridWidth
                contentHeight: gridContent.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.VerticalFlick

                Grid {
                    id: gridContent
                    columns: root.gridCols
                    spacing: root.cellGap
                    width: root.gridWidth

                    Repeater {
                        model: folderModel

                        delegate: Item {
                            id: cellItem
                            width: root.cellSize
                            height: root.cellSize

                            required property int index
                            required property url fileUrl

                            readonly property string filePath: {
                                var s = cellItem.fileUrl.toString()
                                return s.replace("file://", "")
                            }

                            readonly property bool isCurrent:
                                cellItem.filePath !== "" && cellItem.filePath === WallpaperService.currentWallpaper

                            property bool _hovered: false

                            Rectangle {
                                anchors.fill: parent
                                radius: 8
                                clip: true
                                border.width: cellItem.isCurrent ? 2 : 1
                                border.color: cellItem.isCurrent
                                    ? Theme.primary
                                    : Theme.withAlpha(Theme.outline, 0.3)
                                color: cellItem._hovered
                                    ? Theme.surfaceHover
                                    : Theme.withAlpha(Theme.surface, 0.5)

                                Behavior on color {
                                    enabled: SettingsService.animationsEnabled
                                    ColorAnimation { duration: Appearance.anim.quick }
                                }

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: cellItem.isCurrent ? 2 : 1
                                    source: cellItem.fileUrl
                                    sourceSize: Qt.size(root.cellSize * 2, root.cellSize * 2)
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    smooth: true
                                    cache: false
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: cellItem._hovered = true
                                    onExited: cellItem._hovered = false
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: WallpaperService.setWallpaper(cellItem.filePath)
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                visible: gridFlick.contentHeight > gridFlick.height
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: 1
                width: 3
                radius: 2
                color: Theme.withAlpha(Theme.outline, 0.15)

                Rectangle {
                    width: parent.width
                    height: Math.max(24, parent.height * (gridFlick.height / Math.max(gridFlick.contentHeight, 1)))
                    y: (parent.height - height) * (gridFlick.contentY / Math.max(gridFlick.contentHeight - gridFlick.height, 1))
                    radius: 2
                    color: Theme.withAlpha(Theme.primary, 0.6)
                }
            }
        }
    }
}
