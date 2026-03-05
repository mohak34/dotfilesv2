import QtQuick
import qs.Common
import qs.Services

Item {
    id: root

    required property string summary
    required property string body
    required property string appName
    required property string appIcon
    required property int urgency
    required property real timestamp
    property string notifImage: ""
    property var actions: []
    property bool showActions: true
    property bool showDismiss: true
    property bool bodyExpanded: false

    signal dismissed()
    signal actionInvoked(var action)

    implicitWidth: 340
    implicitHeight: cardBg.implicitHeight

    property bool _hovered: false

    Rectangle {
        id: cardBg
        width: parent.width
        implicitHeight: contentCol.implicitHeight + 24
        radius: 12
        clip: true
        color: Theme.withAlpha(Theme.surface, 0.95)
        border.width: root.urgency === 2 ? 2 : 1
        border.color: root.urgency === 2
            ? Theme.withAlpha(Theme.primary, 0.3)
            : Theme.withAlpha(Theme.outline, 0.1)

        Behavior on color {
            enabled: SettingsService.animationsEnabled
            ColorAnimation { duration: Appearance.anim.quick }
        }

        Rectangle {
            visible: root.urgency === 2
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 3
            radius: 12
            color: Theme.primary
        }

        Column {
            id: contentCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            anchors.rightMargin: (root.showDismiss ? 32 : 12) + (root.notifImage !== "" ? 48 : 0)
            spacing: 4

            Row {
                width: parent.width
                spacing: 6

                Image {
                    id: appIconImage
                    visible: root.appIcon !== "" && status === Image.Ready
                    source: root.appIcon === "" ? ""
                        : (root.appIcon.startsWith("file://") || root.appIcon.startsWith("image://") || root.appIcon.startsWith("/"))
                            ? root.appIcon
                            : ("image://icon/" + root.appIcon)
                    width: 14
                    height: 14
                    sourceSize.width: 14
                    sourceSize.height: 14
                    anchors.verticalCenter: parent.verticalCenter
                    asynchronous: true
                }

                Text {
                    text: root.appName || "Notification"
                    color: Theme.surfaceVariantText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Normal
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: timeText
                    text: root.timestamp > 0 ? NotificationService.formatRelativeTime(root.timestamp) : ""
                    color: Theme.surfaceVariantText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.Normal
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                visible: root.summary !== ""
                text: root.summary
                color: Theme.surfaceText
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSize
                font.weight: Font.Bold
                wrapMode: Text.WordWrap
                width: parent.width
                elide: Text.ElideRight
                maximumLineCount: 2
            }

            Text {
                id: bodyText
                visible: root.body !== ""
                text: root.body
                color: Theme.surfaceVariantText
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                font.weight: Font.Normal
                wrapMode: Text.WordWrap
                width: parent.width
                maximumLineCount: root.bodyExpanded ? 9999 : 4
                elide: root.bodyExpanded ? Text.ElideNone : Text.ElideRight
            }

            Text {
                visible: root.body !== "" && (bodyText.truncated || root.bodyExpanded)
                text: root.bodyExpanded ? "show less" : "show more"
                color: Theme.primary
                font.family: Appearance.fontFamily
                font.pixelSize: 10
                font.weight: Font.Bold

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.bodyExpanded = !root.bodyExpanded
                }
            }

            Row {
                visible: root.showActions && root.actions && root.actions.length > 0
                spacing: 6
                topPadding: 4

                Repeater {
                    model: (root.showActions && root.actions) ? root.actions : []

                    delegate: Rectangle {
                        required property var modelData
                        width: actionLabel.implicitWidth + 16
                        height: actionLabel.implicitHeight + 8
                        radius: 6
                        color: actionMouse.containsMouse
                            ? Theme.withAlpha(Theme.primary, 0.2)
                            : Theme.withAlpha(Theme.surfaceVariant, 0.3)

                        Text {
                            id: actionLabel
                            anchors.centerIn: parent
                            text: modelData.text ?? ""
                            color: Theme.primary
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.actionInvoked(modelData)
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            visible: root.showDismiss
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 8
            anchors.rightMargin: 8
            width: 18
            height: 18
            radius: 9
            color: dismissMouse.containsMouse
                ? Theme.withAlpha(Theme.error, 0.2)
                : "transparent"

            Text {
                anchors.centerIn: parent
                text: "\u00d7"
                color: dismissMouse.containsMouse ? Theme.error : Theme.surfaceVariantText
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            MouseArea {
                id: dismissMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.dismissed()
            }
        }

        Rectangle {
            visible: root.notifImage !== "" && notifImageItem.status === Image.Ready
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 28
            anchors.rightMargin: root.showDismiss ? 28 : 8
            width: 28
            height: 28
            radius: 6
            clip: true
            color: Theme.withAlpha(Theme.surfaceVariant, 0.2)

            Image {
                id: notifImageItem
                anchors.fill: parent
                source: root.notifImage
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(56, 56)
                asynchronous: true
                cache: false

                onStatusChanged: {
                    if (status === Image.Ready && root.notifImage.toString().indexOf("image://") === 0) {
                        grabToImage(function(result) {
                            var path = NotificationService.imageCachePath + "/notif_" + root.timestamp + ".png"
                            result.saveToFile(path)
                            NotificationService.updateHistoryImage(root.timestamp, "file://" + path)
                        })
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            onEntered: root._hovered = true
            onExited: root._hovered = false
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    root.dismissed()
                } else if (root.actions && root.actions.length > 0) {
                    root.actionInvoked(root.actions[0])
                }
            }
        }
    }
}
