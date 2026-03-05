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
            text: "POPUPS"
            color: Theme.withAlpha(Theme.surfaceVariantText, 0.7)
            font.family: Appearance.fontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
            font.letterSpacing: 0.8
        }

        Row {
            spacing: 6

            SettingsPill {
                label: "Calendar"
                active: SettingsService.showCalendar
                onClicked: SettingsService.toggleCalendar()
            }

            SettingsPill {
                label: "Battery Stats"
                active: SettingsService.showBatteryPopup
                onClicked: SettingsService.toggleBatteryPopup()
            }
        }
    }
}
