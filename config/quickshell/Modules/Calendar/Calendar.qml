import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services

PanelWindow {
    id: calendarWindow
    visible: ShellState.calendarOpen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: ShellState.calendarOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell:calendar"

    anchors { top: true; left: true; right: true; bottom: true }
    color: "transparent"

    Connections {
        target: ShellState
        function onCalendarOpenChanged() {
            if (ShellState.calendarOpen) {
                calendarRoot.refresh()
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.closeCalendar()
    }

    Rectangle {
        id: calendarRoot

        property var currentDate: new Date()
        property int currentMonth: currentDate.getMonth()
        property int currentYear: currentDate.getFullYear()

        function refresh() {
            currentDate = new Date()
            currentMonth = currentDate.getMonth()
            currentYear = currentDate.getFullYear()
            updateDaysModel()
        }

        function prevMonth() {
            if (currentMonth === 0) {
                currentMonth = 11
                currentYear--
            } else {
                currentMonth--
            }
            updateDaysModel()
        }

        function nextMonth() {
            if (currentMonth === 11) {
                currentMonth = 0
                currentYear++
            } else {
                currentMonth++
            }
            updateDaysModel()
        }

        function updateDaysModel() {
            daysModel.clear()
            var firstDay = new Date(currentYear, currentMonth, 1).getDay()
            var daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate()
            var daysInPrevMonth = new Date(currentYear, currentMonth, 0).getDate()
            var today = new Date()

            for (var i = 0; i < firstDay; i++) {
                var d = daysInPrevMonth - firstDay + i + 1
                daysModel.append({ day: d, isCurrentMonth: false, isToday: false })
            }
            for (var i = 1; i <= daysInMonth; i++) {
                var isToday = (today.getDate() === i && today.getMonth() === currentMonth && today.getFullYear() === currentYear)
                daysModel.append({ day: i, isCurrentMonth: true, isToday: isToday })
            }
            var remaining = 42 - daysModel.count
            for (var i = 1; i <= remaining; i++) {
                daysModel.append({ day: i, isCurrentMonth: false, isToday: false })
            }
        }

        Component.onCompleted: refresh()

        x: (calendarWindow.width - width) / 2
        y: calendarWindow.height - Appearance.barHeight - height
        width: 280
        height: 320
        radius: Appearance.popout.radius
        color: Theme.withAlpha(Theme.background, 0.95)

        MouseArea { anchors.fill: parent }

        ListModel {
            id: daysModel
        }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Row {
                id: header
                width: parent.width
                height: 30
                spacing: 8

                Text {
                    id: prevBtn
                    text: "<"
                    width: 24
                    height: parent.height
                    color: Theme.surfaceText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calendarRoot.prevMonth()
                    }
                }

                Text {
                    id: monthYear
                    text: new Date(calendarRoot.currentYear, calendarRoot.currentMonth, 1).toLocaleDateString(Qt.locale(), "MMMM yyyy")
                    width: parent.width - 48
                    height: parent.height
                    color: Theme.surfaceText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    id: nextBtn
                    text: ">"
                    width: 24
                    height: parent.height
                    color: Theme.surfaceText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calendarRoot.nextMonth()
                    }
                }
            }

            Row {
                id: weekdays
                width: parent.width
                height: 24
                spacing: 0

                ListModel {
                    id: weekdayModel
                    ListElement { day: "Su" }
                    ListElement { day: "Mo" }
                    ListElement { day: "Tu" }
                    ListElement { day: "We" }
                    ListElement { day: "Th" }
                    ListElement { day: "Fr" }
                    ListElement { day: "Sa" }
                }

                Repeater {
                    model: weekdayModel
                    Text {
                        width: (calendarRoot.width - 32) / 7
                        height: parent.height
                        text: day
                        color: Theme.surfaceVariantText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Grid {
                id: daysGrid
                width: parent.width
                height: parent.height - header.height - weekdays.height - 12
                columns: 7
                spacing: 2

                Repeater {
                    model: daysModel
                    Rectangle {
                        width: (calendarRoot.width - 32 - 12) / 7
                        height: (daysGrid.height - 10) / 6
                        radius: 4
                        color: {
                            if (isToday) return Theme.primary
                            return "transparent"
                        }

                        Text {
                            anchors.centerIn: parent
                            text: day
                            color: {
                                if (isToday) return Theme.primaryText
                                if (!isCurrentMonth) return Theme.surfaceVariantText
                                return Theme.surfaceText
                            }
                            font.family: Appearance.fontFamily
                            font.pixelSize: 12
                            font.weight: isToday ? Font.Bold : Font.Normal
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
