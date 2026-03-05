import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services

PanelWindow {
    id: clipboardPopup

    visible: ShellState.clipboardOpen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "quickshell:clipboard"

    anchors { top: true; left: true; right: true; bottom: true }
    color: "transparent"

    property int selectedIndex: 0

    function scrollToSelected() {
        var itemHeight = 52
        var itemTop = selectedIndex * itemHeight
        var itemBottom = itemTop + 50
        
        if (itemTop < clipboardListFlickable.contentY) {
            clipboardListFlickable.contentY = itemTop
        } else if (itemBottom > clipboardListFlickable.contentY + clipboardListFlickable.height) {
            clipboardListFlickable.contentY = itemBottom - clipboardListFlickable.height
        }
    }

    function copySelected() {
        var items = ClipboardService.filteredItems
        if (items.length > 0 && selectedIndex < items.length) {
            ClipboardService.copyItem(items[selectedIndex].id)
            ShellState.closeClipboard()
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.closeClipboard()
    }

    Rectangle {
        id: popupRect
        anchors.centerIn: parent
        width: 600
        height: 500
        radius: Appearance.popout.radius
        color: Theme.withAlpha(Theme.background, 0.95)

        MouseArea { anchors.fill: parent }

        FocusScope {
            id: keyHandler
            anchors.fill: parent
            focus: true

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    ShellState.closeClipboard()
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    copySelected()
                    event.accepted = true
                } else if (event.key === Qt.Key_Down) {
                    if (selectedIndex < ClipboardService.filteredItems.length - 1) {
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

                Item {
                    width: parent.width
                    height: 32

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Clipboard History"
                        color: Theme.surfaceText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 80
                        height: 28
                        radius: 6
                        color: clearMouse.containsMouse
                            ? Theme.withAlpha(Theme.error, 0.3)
                            : Theme.withAlpha(Theme.error, 0.2)
                        visible: ClipboardService.clipboardItems.length > 0

                        Text {
                            anchors.centerIn: parent
                            text: "Clear All"
                            color: Theme.error
                            font.family: Appearance.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ClipboardService.clearAll()
                        }
                    }
                }

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
                                ClipboardService.filterItems(text)
                                selectedIndex = 0
                                clipboardListFlickable.contentY = 0
                            }
                        }
                    }
                }

                Flickable {
                    id: clipboardListFlickable
                    width: parent.width
                    height: parent.height - 100
                    contentHeight: clipboardList.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: clipboardList
                        width: parent.width
                        spacing: 2

                        Repeater {
                            model: ClipboardService.filteredItems

                            delegate: Rectangle {
                                required property var modelData
                                required property int index

                                width: clipboardList.width
                                height: 50
                                radius: 6
                                color: index === selectedIndex
                                    ? Theme.withAlpha(Theme.primary, 0.2)
                                    : (itemMouse.containsMouse
                                        ? Theme.withAlpha(Theme.surfaceVariant, 0.3)
                                        : "transparent")

                                MouseArea {
                                    id: itemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        selectedIndex = index
                                        ClipboardService.copyItem(modelData.id)
                                        ShellState.closeClipboard()
                                    }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 0

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        width: parent.width - 40

                                        Text {
                                            text: modelData.displayText
                                            color: index === selectedIndex ? Theme.primary : Theme.surfaceText
                                            font.family: Appearance.fontFamily
                                            font.pixelSize: 13
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }

                                        Text {
                                            text: modelData.isImage
                                                ? modelData.timestamp + " (" + modelData.imageSize + ")"
                                                : modelData.timestamp
                                            color: Theme.outline
                                            font.family: Appearance.fontFamily
                                            font.pixelSize: 11
                                        }
                                    }

                                    Item { width: 12; height: 1 }

                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 28
                                        height: 28
                                        radius: 4
                                        color: deleteMouse.containsMouse
                                            ? Theme.withAlpha(Theme.error, 0.3)
                                            : "transparent"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "\u00d7"
                                            color: deleteMouse.containsMouse ? Theme.error : Theme.surfaceVariantText
                                            font.family: Appearance.fontFamily
                                            font.pixelSize: 18
                                            font.weight: Font.Bold
                                        }

                                        MouseArea {
                                            id: deleteMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: ClipboardService.deleteItem(modelData.id)
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            visible: ClipboardService.ready && ClipboardService.filteredItems.length === 0
                            anchors.horizontalCenter: parent.horizontalCenter
                            topPadding: 100
                            text: ClipboardService.searchText !== "" 
                                ? "No matching items" 
                                : "No clipboard history"
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
                ClipboardService.filterItems("")
                ClipboardService.refresh()
                selectedIndex = 0
                clipboardListFlickable.contentY = 0
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
