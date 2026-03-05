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
            text: "GAME MODE"
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
                active: SettingsService.gameModeEnabled
                onClicked: SettingsService.setGameMode(true)
            }

            SettingsPill {
                label: "Off"
                active: !SettingsService.gameModeEnabled
                onClicked: SettingsService.setGameMode(false)
            }
        }

        Text {
            text: "Disables blur, reduces opacity"
            color: Theme.withAlpha(Theme.surfaceVariantText, 0.5)
            font.family: Appearance.fontFamily
            font.pixelSize: 10
        }
    }
}
