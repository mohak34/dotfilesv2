import QtQuick
import qs.Common
import qs.Services

Column {
    width: parent ? parent.width : 0
    spacing: 16

    Column {
        width: parent.width
        spacing: 6

        Text {
            text: "THEME SOURCE"
            color: Theme.withAlpha(Theme.surfaceVariantText, 0.7)
            font.family: Appearance.fontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
            font.letterSpacing: 0.8
        }

        Row {
            spacing: 6

            SettingsPill {
                label: "Wallpaper"
                active: WallpaperService.useMatugen
                onClicked: WallpaperService.useMatugen = true
            }

            SettingsPill {
                label: "Preset"
                active: !WallpaperService.useMatugen
                onClicked: WallpaperService.useMatugen = false
            }
        }
    }

    Column {
        width: parent.width
        spacing: 6

        Text {
            text: "COLOR SCHEME"
            color: Theme.withAlpha(Theme.surfaceVariantText, 0.7)
            font.family: Appearance.fontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
            font.letterSpacing: 0.8
        }

        Row {
            spacing: 6

            SettingsPill {
                label: "Tonal"
                active: WallpaperService.colorScheme === "tonal-spot"
                onClicked: WallpaperService.colorScheme = "tonal-spot"
            }

            SettingsPill {
                label: "Mono"
                active: WallpaperService.colorScheme === "monochrome"
                onClicked: WallpaperService.colorScheme = "monochrome"
            }

            SettingsPill {
                label: "Neutral"
                active: WallpaperService.colorScheme === "neutral"
                onClicked: WallpaperService.colorScheme = "neutral"
            }

            SettingsPill {
                label: "Vibrant"
                active: WallpaperService.colorScheme === "vibrant"
                onClicked: WallpaperService.colorScheme = "vibrant"
            }
        }
    }

    Column {
        width: parent.width
        spacing: 6

        Text {
            text: "THEMING"
            color: Theme.withAlpha(Theme.surfaceVariantText, 0.7)
            font.family: Appearance.fontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
            font.letterSpacing: 0.8
        }

        Row {
            spacing: 6

            SettingsPill {
                label: "On"
                active: WallpaperService.wallpaperThemingEnabled
                onClicked: WallpaperService.wallpaperThemingEnabled = true
            }

            SettingsPill {
                label: "Off"
                active: !WallpaperService.wallpaperThemingEnabled
                onClicked: WallpaperService.wallpaperThemingEnabled = false
            }
        }
    }
}
