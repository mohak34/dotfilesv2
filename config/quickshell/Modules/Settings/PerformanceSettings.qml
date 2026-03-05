import QtQuick
import qs.Common
import qs.Services

Item {
    anchors.fill: parent

    Column {
        width: parent.width
        spacing: 20

        Column {
            width: parent.width
            spacing: 8

            Text {
                text: "Game Mode"
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
                    active: SettingsService.gameModeEnabled
                    onClicked: SettingsService.setGameMode(true)
                }

                SettingsTogglePill {
                    label: "Off"
                    active: !SettingsService.gameModeEnabled
                    onClicked: SettingsService.setGameMode(false)
                }
            }

            Text {
                text: "Disables blur, animations, reduces opacity"
                color: Theme.withAlpha(Theme.surfaceVariantText, 0.6)
                font.family: Appearance.fontFamily
                font.pixelSize: 11
            }
        }

        Column {
            width: parent.width
            spacing: 8

            Text {
                text: "Compositor Effects"
                color: Theme.surfaceVariantText
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
                font.letterSpacing: 0.5
            }

            Row {
                spacing: 6

                SettingsTogglePill {
                    label: "Animations"
                    active: SettingsService.animationsEnabled
                    onClicked: SettingsService.toggleAnimations()
                }

                SettingsTogglePill {
                    label: "Blur"
                    active: SettingsService.blurEnabled
                    onClicked: SettingsService.toggleBlur()
                }
            }
        }
    }
}
