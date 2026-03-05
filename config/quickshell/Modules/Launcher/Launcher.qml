import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services

PanelWindow {
    id: launcherWindow

    visible: ShellState.launcherOpen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "quickshell:launcher"

    anchors { top: true; left: true; right: true; bottom: true }
    color: "transparent"

    property int selectedIndex: 0

    function scrollToSelected() {
        var itemH = 46
        var itemTop = selectedIndex * itemH
        var itemBottom = itemTop + 44
        if (itemTop < appListFlickable.contentY) {
            appListFlickable.contentY = itemTop
        } else if (itemBottom > appListFlickable.contentY + appListFlickable.height) {
            appListFlickable.contentY = itemBottom - appListFlickable.height
        }
    }

    function launchSelected() {
        var apps = AppLauncherService.filteredApps
        if (apps.length > 0 && selectedIndex < apps.length)
            AppLauncherService.launchApp(apps[selectedIndex])
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.closeLauncher()
    }

    Rectangle {
        id: popupRect
        anchors.centerIn: parent
        width: 600
        height: 400
        radius: Appearance.popout.radius
        color: Theme.withAlpha(Theme.background, 0.95)

        MouseArea { anchors.fill: parent }

        FocusScope {
            id: keyHandler
            anchors.fill: parent
            focus: true

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    ShellState.closeLauncher()
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    launchSelected()
                    event.accepted = true
                } else if (event.key === Qt.Key_Down) {
                    if (selectedIndex < AppLauncherService.filteredApps.length - 1) {
                        selectedIndex++
                        scrollToSelected()
                    }
                    event.accepted = true
                } else if (event.key === Qt.Key_Up) {
                    if (selectedIndex > 0) {
                        selectedIndex--
                        scrollToSelected()
                    }
                    event.accepted = true
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Rectangle {
                    width: parent.width
                    height: 40
                    radius: 8
                    color: Theme.withAlpha(Theme.surfaceVariant, 0.2)

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\udb81\udd7d"
                            color: Theme.surfaceVariantText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 16
                        }

                        TextInput {
                            id: searchInput
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 40
                            color: Theme.surfaceText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 14
                            selectionColor: Theme.primary
                            selectedTextColor: Theme.primaryText
                            focus: true

                            Keys.forwardTo: [keyHandler]

                            onTextChanged: {
                                AppLauncherService.filterApps(text)
                                selectedIndex = 0
                                appListFlickable.contentY = 0
                            }
                        }
                    }
                }

                Flickable {
                    id: appListFlickable
                    width: parent.width
                    height: parent.height - 60
                    contentHeight: appList.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: appList
                        width: parent.width
                        spacing: 2

                        Repeater {
                            model: AppLauncherService.filteredApps

                            delegate: Rectangle {
                                required property var modelData
                                required property int index

                                width: appList.width
                                height: 44
                                radius: 6
                                color: index === selectedIndex
                                    ? Theme.withAlpha(Theme.primary, 0.2)
                                    : (appMouse.containsMouse
                                        ? Theme.withAlpha(Theme.surfaceVariant, 0.3)
                                        : "transparent")

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 12

                                    Image {
                                        anchors.verticalCenter: parent.verticalCenter
                                        source: modelData.icon
                                            ? (modelData.icon.startsWith("/") ? modelData.icon : "image://icon/" + modelData.icon)
                                            : ""
                                        width: 24
                                        height: 24
                                        sourceSize: Qt.size(24, 24)
                                        visible: status === Image.Ready
                                        asynchronous: true
                                    }

                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 24
                                        height: 24
                                        radius: 4
                                        color: Theme.withAlpha(Theme.surfaceVariant, 0.3)
                                        visible: !parent.children[0].visible

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.name.charAt(0).toUpperCase()
                                            color: Theme.surfaceVariantText
                                            font.family: Appearance.fontFamily
                                            font.pixelSize: 12
                                            font.weight: Font.Bold
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2

                                        Text {
                                            text: modelData.name
                                            color: index === selectedIndex ? Theme.primary : Theme.surfaceText
                                            font.family: Appearance.fontFamily
                                            font.pixelSize: 13
                                            font.weight: Font.Medium
                                        }

                                        Text {
                                            visible: modelData.comment !== ""
                                            text: modelData.comment
                                            color: Theme.surfaceVariantText
                                            font.family: Appearance.fontFamily
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                            width: appList.width - 80
                                        }
                                    }
                                }

                                MouseArea {
                                    id: appMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        selectedIndex = index
                                        AppLauncherService.launchApp(modelData)
                                    }
                                }
                            }
                        }

                        Text {
                            visible: AppLauncherService.ready && AppLauncherService.filteredApps.length === 0
                            anchors.horizontalCenter: parent.horizontalCenter
                            topPadding: 50
                            text: AppLauncherService.searchQuery !== "" ? "No apps found" : "Loading apps..."
                            color: Theme.surfaceVariantText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }

        onVisibleChanged: {
            if (visible) {
                searchInput.text = ""
                AppLauncherService.filterApps("")
                selectedIndex = 0
                appListFlickable.contentY = 0
                focusTimer.start()
            }
        }

        Timer {
            id: focusTimer
            interval: 100
            onTriggered: searchInput.forceActiveFocus()
        }
    }
}
