import QtQuick
import qs.Common
import qs.Services

Item {
    anchors.fill: parent

    Flickable {
        anchors.fill: parent
        contentHeight: col.implicitHeight
        clip: true

        Column {
            id: col
            width: parent.width
            spacing: 20

            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: "Theme Source"
                    color: Theme.surfaceVariantText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.letterSpacing: 0.5
                }

                Row {
                    spacing: 6

                    SettingsTogglePill {
                        label: "Wallpaper"
                        active: WallpaperService.useMatugen
                        onClicked: WallpaperService.useMatugen = true
                    }

                    SettingsTogglePill {
                        label: "Preset"
                        active: !WallpaperService.useMatugen
                        onClicked: WallpaperService.useMatugen = false
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: "Color Scheme"
                    color: Theme.surfaceVariantText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.letterSpacing: 0.5
                }

                Row {
                    spacing: 6

                    SettingsTogglePill {
                        label: "Tonal"
                        active: WallpaperService.colorScheme === "tonal-spot"
                        onClicked: WallpaperService.colorScheme = "tonal-spot"
                    }

                    SettingsTogglePill {
                        label: "Mono"
                        active: WallpaperService.colorScheme === "monochrome"
                        onClicked: WallpaperService.colorScheme = "monochrome"
                    }

                    SettingsTogglePill {
                        label: "Neutral"
                        active: WallpaperService.colorScheme === "neutral"
                        onClicked: WallpaperService.colorScheme = "neutral"
                    }

                    SettingsTogglePill {
                        label: "Vibrant"
                        active: WallpaperService.colorScheme === "vibrant"
                        onClicked: WallpaperService.colorScheme = "vibrant"
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: "Theming"
                    color: Theme.surfaceVariantText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.letterSpacing: 0.5
                }

                Row {
                    spacing: 6

                    SettingsTogglePill {
                        label: "On"
                        active: WallpaperService.wallpaperThemingEnabled
                        onClicked: WallpaperService.wallpaperThemingEnabled = true
                    }

                    SettingsTogglePill {
                        label: "Off"
                        active: !WallpaperService.wallpaperThemingEnabled
                        onClicked: WallpaperService.wallpaperThemingEnabled = false
                    }
                }
            }
        }
    }
}
