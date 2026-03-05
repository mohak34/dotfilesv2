import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services

PanelWindow {
    id: ncWindow

    visible: ShellState.notificationCenterOpen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: ShellState.notificationCenterOpen
        ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell:notification-center"

    anchors { top: true; left: true; right: true; bottom: true }
    color: "transparent"

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.closeNotificationCenter()
    }

    property var _expandedGroups: ({})

    readonly property int _itemCount:
        NotificationService.notifications.length + NotificationService.history.length

    readonly property var _groupedModel: {
        var allItems = []
        var notifs = NotificationService.notifications
        var liveTimestamps = {}

        for (var i = 0; i < notifs.length; i++) {
            liveTimestamps[notifs[i].timestamp] = true
            allItems.push({
                type: "live",
                data: notifs[i],
                summary: notifs[i].summary,
                body: notifs[i].body,
                appName: notifs[i].appName,
                appIcon: notifs[i].appIcon,
                image: notifs[i].image || "",
                urgency: notifs[i].urgency,
                timestamp: notifs[i].timestamp,
                actions: notifs[i].notification ? notifs[i].notification.actions : [],
                historyIndex: -1
            })
        }

        var hist = NotificationService.history
        for (var j = 0; j < hist.length; j++) {
            if (liveTimestamps[hist[j].timestamp]) continue
            allItems.push({
                type: "history",
                data: hist[j],
                summary: hist[j].summary,
                body: hist[j].body,
                appName: hist[j].appName,
                appIcon: hist[j].appIcon,
                image: hist[j].image || "",
                urgency: hist[j].urgency,
                timestamp: hist[j].timestamp,
                actions: [],
                historyIndex: j
            })
        }

        var groups = {}
        for (var k = 0; k < allItems.length; k++) {
            var key = (allItems[k].appName || "Unknown").toLowerCase()
            if (!groups[key]) {
                groups[key] = {
                    appName: allItems[k].appName || "Unknown",
                    appIcon: allItems[k].appIcon || "",
                    groupKey: key,
                    items: [],
                    latestTimestamp: 0,
                    count: 0
                }
            }
            groups[key].items.push(allItems[k])
            groups[key].count++
            if (allItems[k].timestamp > groups[key].latestTimestamp)
                groups[key].latestTimestamp = allItems[k].timestamp
        }

        var sorted = []
        for (var gk in groups) sorted.push(groups[gk])
        sorted.sort(function(a, b) { return b.latestTimestamp - a.latestTimestamp })

        for (var g = 0; g < sorted.length; g++) {
            sorted[g].items.sort(function(a, b) { return b.timestamp - a.timestamp })
        }

        return sorted
    }

    function _toggleGroup(groupKey) {
        var copy = {}
        for (var k in _expandedGroups) copy[k] = _expandedGroups[k]
        if (copy[groupKey]) delete copy[groupKey]
        else copy[groupKey] = true
        _expandedGroups = copy
    }

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Appearance.barHeight
        width: Appearance.popout.ncWidth
        color: Theme.withAlpha(Theme.background, 0.95)

        MouseArea { anchors.fill: parent }

        Column {
            id: panelHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 12

            Row {
                width: parent.width

                Text {
                    text: "Notifications"
                    color: Theme.surfaceText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    width: parent.width - closeBtnRow.width
                    anchors.verticalCenter: parent.verticalCenter
                }

                Row {
                    id: closeBtnRow
                    spacing: 6
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: clearLabel.implicitWidth + 16
                        height: clearLabel.implicitHeight + 8
                        radius: 6
                        color: clearMouse.containsMouse
                            ? Theme.withAlpha(Theme.error, 0.2)
                            : Theme.withAlpha(Theme.surfaceVariant, 0.2)
                        visible: ncWindow._itemCount > 0

                        Text {
                            id: clearLabel
                            anchors.centerIn: parent
                            text: "Clear All"
                            color: clearMouse.containsMouse ? Theme.error : Theme.surfaceVariantText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                NotificationService.clearAll()
                                NotificationService.clearHistory()
                                ncWindow._expandedGroups = ({})
                            }
                        }
                    }

                    Rectangle {
                        width: closeLabelNC.implicitWidth + 16
                        height: closeLabelNC.implicitHeight + 8
                        radius: 6
                        color: closeMouseNC.containsMouse
                            ? Theme.withAlpha(Theme.error, 0.2)
                            : Theme.withAlpha(Theme.surfaceVariant, 0.2)

                        Text {
                            id: closeLabelNC
                            anchors.centerIn: parent
                            text: "\u2715"
                            color: closeMouseNC.containsMouse ? Theme.error : Theme.surfaceVariantText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: closeMouseNC
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ShellState.closeNotificationCenter()
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.withAlpha(Theme.outline, 0.15)
            }
        }

        Text {
            anchors.centerIn: parent
            visible: ncWindow._itemCount === 0
            text: "No notifications"
            color: Theme.surfaceVariantText
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSize
        }

        Flickable {
            anchors.top: panelHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: 12
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.bottomMargin: 16
            contentHeight: groupColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            visible: ncWindow._itemCount > 0

            Column {
                id: groupColumn
                width: parent.width
                spacing: 12

                Repeater {
                    model: ncWindow._groupedModel

                    delegate: Column {
                        id: groupDelegate
                        required property var modelData
                        required property int index
                        width: groupColumn.width
                        spacing: 4

                        Rectangle {
                            visible: true
                            width: parent.width
                            height: 32
                            radius: 8
                            color: groupHeaderMouse.containsMouse && groupDelegate.modelData.count > 1
                                ? Theme.withAlpha(Theme.surfaceVariant, 0.25)
                                : Theme.withAlpha(Theme.surfaceVariant, 0.15)

                            MouseArea {
                                id: groupHeaderMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: groupDelegate.modelData.count > 1
                                cursorShape: groupDelegate.modelData.count > 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: ncWindow._toggleGroup(groupDelegate.modelData.groupKey)
                            }

                            Item {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10

                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 6

                                    Image {
                                        source: groupDelegate.modelData.appIcon === "" ? ""
                                            : (groupDelegate.modelData.appIcon.startsWith("file://") || groupDelegate.modelData.appIcon.startsWith("image://") || groupDelegate.modelData.appIcon.startsWith("/"))
                                                ? groupDelegate.modelData.appIcon
                                                : ("image://icon/" + groupDelegate.modelData.appIcon)
                                        width: 16
                                        height: 16
                                        sourceSize: Qt.size(16, 16)
                                        visible: groupDelegate.modelData.appIcon !== "" && status === Image.Ready
                                        anchors.verticalCenter: parent.verticalCenter
                                        asynchronous: true
                                    }

                                    Text {
                                        text: groupDelegate.modelData.appName
                                        color: Theme.surfaceText
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Rectangle {
                                        visible: groupDelegate.modelData.count > 1
                                        width: countText.implicitWidth + 10
                                        height: 16
                                        radius: 8
                                        color: Theme.withAlpha(Theme.primary, 0.2)
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            id: countText
                                            anchors.centerIn: parent
                                            text: groupDelegate.modelData.count
                                            color: Theme.primary
                                            font.family: Appearance.fontFamily
                                            font.pixelSize: 10
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 18
                                    height: 18
                                    radius: 9
                                    color: dismissGroupMouse.containsMouse
                                        ? Theme.withAlpha(Theme.error, 0.2)
                                        : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "\u00d7"
                                        color: dismissGroupMouse.containsMouse ? Theme.error : Theme.surfaceVariantText
                                        font.pixelSize: 14
                                        font.weight: Font.Bold
                                    }

                                    MouseArea {
                                        id: dismissGroupMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            mouse.accepted = true
                                            NotificationService.dismissGroup(groupDelegate.modelData.appName)
                                        }
                                    }
                                }
                            }

                        }

                        Column {
                            id: innerCardCol
                            width: parent.width
                            spacing: 4

                            Repeater {
                                model: {
                                    var _ = ncWindow._expandedGroups
                                    var items = groupDelegate.modelData.items
                                    if (groupDelegate.modelData.count === 1) return items
                                    if (ncWindow._expandedGroups[groupDelegate.modelData.groupKey]) return items
                                    return [items[0]]
                                }

                                delegate: NotificationCard {
                                    required property var modelData
                                    width: innerCardCol.width

                                    summary: modelData.summary
                                    body: modelData.body
                                    appName: modelData.appName
                                    appIcon: modelData.appIcon
                                    notifImage: modelData.image || ""
                                    urgency: modelData.urgency
                                    timestamp: modelData.timestamp
                                    actions: modelData.actions || []
                                    showActions: modelData.type === "live"
                                    showDismiss: true

                                    onDismissed: {
                                        if (modelData.type === "live") {
                                            NotificationService.dismissByTimestamp(modelData.timestamp)
                                        } else {
                                            NotificationService.removeHistoryItem(modelData.historyIndex)
                                        }
                                    }
                                    onActionInvoked: function(action) {
                                        try { action.invoke() } catch(e) {}
                                        if (modelData.type === "live") {
                                            NotificationService.dismissNotification(modelData.data)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                ShellState.closeNotificationCenter()
                event.accepted = true
            }
        }
    }
}
