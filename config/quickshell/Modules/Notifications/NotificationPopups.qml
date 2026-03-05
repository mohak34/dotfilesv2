import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services

Scope {
    id: root
    required property var screen

    PanelWindow {
        id: popupWindow

        screen: root.screen
        visible: NotificationService.hasPopupContent

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:notifications"

        anchors {
            top: true
            right: true
        }

        implicitWidth: 360
        implicitHeight: contentColumn.implicitHeight + 16

        color: "transparent"

        Column {
            id: contentColumn
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 8
            anchors.rightMargin: 10
            spacing: 8

            OsdCard {
                visible: NotificationService.osdType !== ""
                icon: NotificationService.osdIcon
                value: NotificationService.osdValue
                muted: NotificationService.osdMuted

                opacity: visible ? 1 : 0
                Behavior on opacity {
                    enabled: SettingsService.animationsEnabled
                    NumberAnimation { duration: Appearance.anim.quick }
                }
            }

            Repeater {
                model: NotificationService.popupNotifications

                delegate: NotificationCard {
                    required property var modelData

                    summary: modelData.summary
                    body: modelData.body
                    appName: modelData.appName
                    appIcon: modelData.appIcon
                    urgency: modelData.urgency
                    timestamp: modelData.timestamp
                    notifImage: modelData.image || ""
                    actions: modelData.notification ? modelData.notification.actions : []
                    showActions: true
                    showDismiss: true

                    onDismissed: NotificationService.dismissPopup(modelData.timestamp)
                    onActionInvoked: action => {
                        try { action.invoke() } catch(e) {}
                        NotificationService.dismissNotification(modelData)
                    }

                    opacity: 1
                    Behavior on opacity {
                        enabled: SettingsService.animationsEnabled
                        NumberAnimation { duration: Appearance.anim.quick }
                    }
                }
            }
        }
    }
}
