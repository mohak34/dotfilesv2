import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Services

Item {
    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "ddd, MMM dd - hh:mm")
        color: Theme.surfaceText
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSize
        font.weight: Appearance.fontWeight
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: SettingsService.showCalendar
        onClicked: ShellState.toggleCalendar()
    }
}
