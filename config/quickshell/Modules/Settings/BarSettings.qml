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
                text: "Bar Position"
                color: Theme.surfaceVariantText
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
                font.letterSpacing: 0.5
            }

            Row {
                spacing: 6

                SettingsTogglePill {
                    label: "Bottom"
                    active: !SettingsService.barAtTop
                    onClicked: SettingsService.setBarPosition(false)
                }

                SettingsTogglePill {
                    label: "Top"
                    active: SettingsService.barAtTop
                    onClicked: SettingsService.setBarPosition(true)
                }
            }
        }
    }
}
