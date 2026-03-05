pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Io

Singleton {
    id: root

    property var notifications: []
    property var popupNotifications: []
    property var history: []
    readonly property bool centerOpen: ShellState.notificationCenterOpen
    property int maxPopups: 4

    property string osdType: ""
    property real osdValue: 0
    property string osdIcon: ""
    property bool osdMuted: false

    property bool _suppressOsd: true
    property int historyMaxAgeDays: 7
    readonly property string historyPath: Quickshell.env("HOME") + "/.cache/quickshell/notification_history.json"
    readonly property string imageCachePath: Quickshell.env("HOME") + "/.cache/quickshell/notification_images"
    readonly property bool hasPopupContent: osdType !== "" || popupNotifications.length > 0

    Timer {
        interval: 2000
        running: true
        onTriggered: root._suppressOsd = false
    }

    Timer {
        id: osdTimer
        interval: 1500
        onTriggered: root.osdType = ""
    }

    Timer {
        id: popupCheckTimer
        interval: 500
        running: root.popupNotifications.length > 0
        repeat: true
        onTriggered: root._pruneExpiredPopups()
    }

    Timer {
        id: historySaveTimer
        interval: 500
        onTriggered: root._saveHistory()
    }

    NotificationServer {
        id: server
        keepOnReload: false
        actionsSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notif => {
            notif.tracked = true

            var wrapper = {
                notification: notif,
                summary: notif.summary ?? "",
                body: notif.body ?? "",
                appName: notif.appName ?? "",
                appIcon: notif.appIcon ?? "",
                image: notif.image ?? "",
                urgency: notif.urgency,
                timestamp: Date.now(),
                timeout: root._timeoutForUrgency(notif.urgency)
            }

            var copy = root.notifications.slice()
            copy.unshift(wrapper)
            root.notifications = copy

            if (!notif.transient) {
                root._addToHistory(wrapper)
            }

            if (!root.centerOpen && !ShellState.dndEnabled) {
                var popups = root.popupNotifications.slice()
                if (popups.length >= root.maxPopups) {
                    popups.pop()
                }
                popups.unshift(wrapper)
                root.popupNotifications = popups
            }
        }
    }

    Connections {
        target: AudioService
        function onSinkVolumeChanged() {
            if (root._suppressOsd) return
            root.showOsd("volume", AudioService.sinkVolume, root._volumeIcon(), AudioService.sinkMuted)
        }
        function onSinkMutedChanged() {
            if (root._suppressOsd) return
            root.showOsd("volume", AudioService.sinkVolume, root._volumeIcon(), AudioService.sinkMuted)
        }
    }

    Connections {
        target: BrightnessService
        function onBrightnessChanged() {
            if (root._suppressOsd) return
            root.showOsd("brightness", BrightnessService.brightness, "\udb80\udce0", false)
        }
    }

    Connections {
        target: ShellState
        function onNotificationCenterOpenChanged() {
            if (ShellState.notificationCenterOpen) {
                root.popupNotifications = []
            }
        }
    }

    function showOsd(type, value, icon, muted) {
        root.osdType = type
        root.osdValue = value
        root.osdIcon = icon
        root.osdMuted = muted
        osdTimer.restart()
    }

    function dismissByTimestamp(timestamp) {
        var idx = -1
        for (var i = 0; i < root.notifications.length; i++) {
            if (root.notifications[i].timestamp === timestamp) { idx = i; break }
        }
        if (idx >= 0) {
            var wrapper = root.notifications[idx]
            try { if (wrapper.notification) wrapper.notification.dismiss() } catch(e) {}
            var copy = root.notifications.slice()
            copy.splice(idx, 1)
            root.notifications = copy
            var pidx = root.popupNotifications.indexOf(wrapper)
            if (pidx >= 0) {
                var pcopy = root.popupNotifications.slice()
                pcopy.splice(pidx, 1)
                root.popupNotifications = pcopy
            }
        }
    }

    function dismissNotification(wrapper) {
        if (!wrapper) return

        try {
            if (wrapper.notification) wrapper.notification.dismiss()
        } catch (e) {}

        var idx = root.notifications.indexOf(wrapper)
        if (idx >= 0) {
            var copy = root.notifications.slice()
            copy.splice(idx, 1)
            root.notifications = copy
        }

        var pidx = root.popupNotifications.indexOf(wrapper)
        if (pidx >= 0) {
            var pcopy = root.popupNotifications.slice()
            pcopy.splice(pidx, 1)
            root.popupNotifications = pcopy
        }
    }

    function dismissPopup(timestamp) {
        var pidx = -1
        for (var i = 0; i < root.popupNotifications.length; i++) {
            if (root.popupNotifications[i].timestamp === timestamp) {
                pidx = i
                break
            }
        }
        if (pidx >= 0) {
            var pcopy = root.popupNotifications.slice()
            pcopy.splice(pidx, 1)
            root.popupNotifications = pcopy
        }
    }

    function clearAll() {
        var copy = root.notifications.slice()
        for (var i = 0; i < copy.length; i++) {
            try {
                if (copy[i].notification) copy[i].notification.dismiss()
            } catch (e) {}
        }
        root.notifications = []
        root.popupNotifications = []
    }

    function clearHistory() {
        root.history = []
        historySaveTimer.restart()
    }

    function removeHistoryItem(index) {
        if (index < 0 || index >= root.history.length) return
        var copy = root.history.slice()
        copy.splice(index, 1)
        root.history = copy
        historySaveTimer.restart()
    }

    function dismissGroup(appName) {
        if (!appName) return

        var notifsCopy = []
        for (var i = 0; i < root.notifications.length; i++) {
            if (root.notifications[i].appName !== appName) {
                notifsCopy.push(root.notifications[i])
            } else {
                try {
                    if (root.notifications[i].notification) {
                        root.notifications[i].notification.dismiss()
                    }
                } catch (e) {}
            }
        }
        root.notifications = notifsCopy

        var popupCopy = []
        for (var j = 0; j < root.popupNotifications.length; j++) {
            if (root.popupNotifications[j].appName !== appName) {
                popupCopy.push(root.popupNotifications[j])
            }
        }
        root.popupNotifications = popupCopy

        var histCopy = []
        for (var k = 0; k < root.history.length; k++) {
            if (root.history[k].appName !== appName) {
                histCopy.push(root.history[k])
            }
        }
        root.history = histCopy

        historySaveTimer.restart()
    }

    function formatRelativeTime(timestamp) {
        var diff = Math.floor((Date.now() - timestamp) / 1000)
        if (diff < 60) return "now"
        if (diff < 3600) return Math.floor(diff / 60) + "m"
        if (diff < 86400) return Math.floor(diff / 3600) + "h"
        return Math.floor(diff / 86400) + "d"
    }

    function pruneHistory() {
        if (root.historyMaxAgeDays <= 0) return
        var cutoff = Date.now() - root.historyMaxAgeDays * 86400000
        var pruned = root.history.filter(function(entry) {
            return entry.timestamp > cutoff
        })
        if (pruned.length !== root.history.length) {
            root.history = pruned
            historySaveTimer.restart()
        }
    }

    function updateHistoryImage(timestamp, imagePath) {
        var copy = root.history.slice()
        for (var i = 0; i < copy.length; i++) {
            if (copy[i].timestamp === timestamp) {
                var updated = {}
                var keys = Object.keys(copy[i])
                for (var k = 0; k < keys.length; k++) updated[keys[k]] = copy[i][keys[k]]
                updated.image = imagePath
                copy[i] = updated
                root.history = copy
                historySaveTimer.restart()
                return
            }
        }
    }

    function _timeoutForUrgency(urgency) {
        switch (urgency) {
        case NotificationUrgency.Low: return 3000
        case NotificationUrgency.Critical: return 10000
        default: return 5000
        }
    }

    function _volumeIcon() {
        if (AudioService.sinkMuted) return "\udb81\udf5f"
        if (AudioService.sinkVolume <= 0) return "\udb81\udd7f"
        if (AudioService.sinkVolume < 50) return "\udb81\udd80"
        return "\udb81\udd7e"
    }

    function _pruneExpiredPopups() {
        var now = Date.now()
        var popups = root.popupNotifications
        var changed = false
        var result = []
        for (var i = 0; i < popups.length; i++) {
            if (now - popups[i].timestamp < popups[i].timeout) {
                result.push(popups[i])
            } else {
                changed = true
            }
        }
        if (changed) root.popupNotifications = result
    }

    function _addToHistory(wrapper) {
        var entry = {
            summary: wrapper.summary,
            body: wrapper.body,
            appName: wrapper.appName,
            appIcon: wrapper.appIcon,
            image: wrapper.image || "",
            urgency: wrapper.urgency,
            timestamp: wrapper.timestamp
        }
        var copy = root.history.slice()
        copy.unshift(entry)
        if (copy.length > 50) copy = copy.slice(0, 50)
        root.history = copy
        historySaveTimer.restart()
    }

    function _saveHistory() {
        var json = JSON.stringify(root.history)
        var encoded = Qt.btoa(json)
        saveProcess.command = ["bash", "-c", "mkdir -p \"$(dirname '" + root.historyPath + "')\" && echo " + encoded + " | base64 -d > '" + root.historyPath + "'"]
        saveProcess.running = true
    }

    function _loadHistory() {
        loadProcess.running = true
    }

    Process {
        id: saveProcess
        running: false
    }

    Process {
        id: loadProcess
        command: ["cat", root.historyPath]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.history = JSON.parse(this.text)
                } catch (e) {
                    root.history = []
                }
                root.pruneHistory()
            }
        }
    }

    Process {
        id: mkdirProcess
        command: ["mkdir", "-p", root.imageCachePath]
        running: false
    }

    Component.onCompleted: {
        mkdirProcess.running = true
        root._loadHistory()
    }
}
