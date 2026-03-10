pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool controlCenterOpen: false
    property bool notificationCenterOpen: false
    property bool dndEnabled: false

    property real ccTriggerX: 0
    property real ccTriggerWidth: 0

    property string expandedDetail: ""
    property string activeTab: "cc"

    function openTab(tab) {
        activeTab = tab
        controlCenterOpen = true
    }

    function toggleControlCenter() {
        controlCenterOpen = !controlCenterOpen
        if (!controlCenterOpen) {
            expandedDetail = ""
            ccTriggerX = 0
            ccTriggerWidth = 0
        }
    }

    function closeControlCenter() {
        controlCenterOpen = false
        expandedDetail = ""
    }

    function openNotificationCenter() {
        notificationCenterOpen = true
    }

    function closeNotificationCenter() {
        notificationCenterOpen = false
    }

    function toggleNotificationCenter() {
        notificationCenterOpen = !notificationCenterOpen
    }

    function toggleDnd() {
        dndEnabled = !dndEnabled
    }

    function toggleDetail(name) {
        expandedDetail = (expandedDetail === name) ? "" : name
    }

    property bool calendarOpen: false

    function toggleCalendar() {
        calendarOpen = !calendarOpen
    }

    function closeCalendar() {
        calendarOpen = false
    }

    property bool batteryPopupOpen: false
    property real batteryTriggerX: 0
    property real batteryTriggerWidth: 0

    function toggleBatteryPopup() {
        batteryPopupOpen = !batteryPopupOpen
    }

    function closeBatteryPopup() {
        batteryPopupOpen = false
    }

    property bool barVisible: true

    function toggleBar() {
        barVisible = !barVisible
    }

    property bool launcherOpen: false

    function toggleLauncher() {
        launcherOpen = !launcherOpen
    }

    function openLauncher() {
        launcherOpen = true
    }

    function closeLauncher() {
        launcherOpen = false
    }

    property bool clipboardOpen: false

    function toggleClipboard() {
        clipboardOpen = !clipboardOpen
    }

    function openClipboard() {
        clipboardOpen = true
    }

    function closeClipboard() {
        clipboardOpen = false
    }

    property bool keybindsOpen: false

    function toggleKeybinds() {
        keybindsOpen = !keybindsOpen
    }

    function openKeybinds() {
        keybindsOpen = true
    }

    function closeKeybinds() {
        keybindsOpen = false
    }
}
