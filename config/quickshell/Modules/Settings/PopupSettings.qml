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
                text: "Popups"
                color: Theme.surfaceVariantText
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
                font.letterSpacing: 0.5
            }

            Row {
                spacing: 6

                SettingsTogglePill {
                    label: "Calendar"
                    active: SettingsService.showCalendar
                    onClicked: SettingsService.toggleCalendar()
                }

                SettingsTogglePill {
                    label: "Battery Stats"
                    active: SettingsService.showBatteryPopup
                    onClicked: SettingsService.toggleBatteryPopup()
                }
            }
        }
    }
}
