import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services

PanelWindow {
    id: keybindsPopup

    visible: ShellState.keybindsOpen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "quickshell:keybinds"

    anchors { top: true; left: true; right: true; bottom: true }
    color: "transparent"

    readonly property var allKeybinds: [
        { category: "QuickShell", mod: "Super", key: "K", desc: "Keybinds viewer" },
        { category: "QuickShell", mod: "Super", key: "A", desc: "App launcher" },
        { category: "QuickShell", mod: "Super", key: "V", desc: "Clipboard history" },
        { category: "QuickShell", mod: "Super", key: "N", desc: "Notification center" },
        { category: "QuickShell", mod: "Super+Shift", key: "A", desc: "Control center" },
        { category: "QuickShell", mod: "Super+Shift", key: "B", desc: "Toggle bar" },

        { category: "Window", mod: "Super", key: "Q", desc: "Close focused window" },
        { category: "Window", mod: "Super", key: "W", desc: "Toggle float" },
        { category: "Window", mod: "Super", key: "F", desc: "Toggle fullscreen" },
        { category: "Window", mod: "Super", key: "G", desc: "Toggle group" },
        { category: "Window", mod: "Super", key: "J", desc: "Toggle split" },
        { category: "Window", mod: "Super", key: "S", desc: "Toggle special workspace (scratchpad)" },
        { category: "Window", mod: "Super+Alt", key: "S", desc: "Move to special workspace (silent)" },
        { category: "Window", mod: "Super", key: "M", desc: "Exit Hyprland" },

        { category: "Applications", mod: "Super", key: "Return", desc: "Terminal (ghostty)" },
        { category: "Applications", mod: "Super", key: "E", desc: "File manager (thunar)" },
        { category: "Applications", mod: "Super", key: "B", desc: "Web browser (zen)" },
        { category: "Applications", mod: "Super+Ctrl", key: "V", desc: "Volume control (pavucontrol)" },
        { category: "Applications", mod: "Super+Ctrl", key: "L", desc: "Lock screen (hyprlock)" },
        { category: "Applications", mod: "Super+Ctrl", key: "Q", desc: "Logout (wlogout)" },
        { category: "Applications", mod: "Ctrl+Alt", key: "W", desc: "Toggle waybar" },
        { category: "Applications", mod: "Super+Ctrl", key: "T", desc: "Theme selector" },

        { category: "Navigation", mod: "Super", key: "H", desc: "Focus left" },
        { category: "Navigation", mod: "Super", key: "L", desc: "Focus right" },
        { category: "Navigation", mod: "Super", key: "K", desc: "Focus up" },
        { category: "Navigation", mod: "Super", key: "J", desc: "Focus down" },
        { category: "Navigation", mod: "Alt", key: "Tab", desc: "Focus down" },
        { category: "Navigation", mod: "Super+Shift", key: "H", desc: "Move window left" },
        { category: "Navigation", mod: "Super+Shift", key: "L", desc: "Move window right" },
        { category: "Navigation", mod: "Super+Shift", key: "K", desc: "Move window up" },
        { category: "Navigation", mod: "Super+Shift", key: "J", desc: "Move window down" },
        { category: "Navigation", mod: "Super+Ctrl", key: "H", desc: "Previous in group" },
        { category: "Navigation", mod: "Super+Ctrl", key: "L", desc: "Next in group" },

        { category: "Workspaces", mod: "Super", key: "1–0", desc: "Switch to workspace 1–10" },
        { category: "Workspaces", mod: "Super+Shift", key: "1–0", desc: "Move window to workspace 1–10" },
        { category: "Workspaces", mod: "Super+Alt", key: "1–0", desc: "Move window silently to workspace 1–10" },
        { category: "Workspaces", mod: "Super+Ctrl", key: "→", desc: "Next workspace" },
        { category: "Workspaces", mod: "Super+Ctrl", key: "←", desc: "Previous workspace" },
        { category: "Workspaces", mod: "Super+Ctrl", key: "↓", desc: "First empty workspace" },
        { category: "Workspaces", mod: "Super+Ctrl+Alt", key: "→", desc: "Move to next workspace" },
        { category: "Workspaces", mod: "Super+Ctrl+Alt", key: "←", desc: "Move to previous workspace" },
        { category: "Workspaces", mod: "Super", key: "Scroll", desc: "Scroll through workspaces" },

        { category: "Resize", mod: "Super+Shift", key: "→", desc: "Resize window right (+30px)" },
        { category: "Resize", mod: "Super+Shift", key: "←", desc: "Resize window left (−30px)" },
        { category: "Resize", mod: "Super+Shift", key: "↑", desc: "Resize window up (−30px)" },
        { category: "Resize", mod: "Super+Shift", key: "↓", desc: "Resize window down (+30px)" },

        { category: "Mouse", mod: "Super", key: "LMB drag", desc: "Move window" },
        { category: "Mouse", mod: "Super", key: "RMB drag", desc: "Resize window" },
        { category: "Mouse", mod: "Super", key: "Z drag", desc: "Move window" },
        { category: "Mouse", mod: "Super", key: "X drag", desc: "Resize window" },

        { category: "Screenshots", mod: "", key: "Print", desc: "Fullscreen screenshot" },
        { category: "Screenshots", mod: "Super", key: "Print", desc: "Smart screenshot (region/window)" },
        { category: "Screenshots", mod: "Super+Shift", key: "S", desc: "Region selection screenshot" },
        { category: "Screenshots", mod: "Super+Alt+Shift", key: "S", desc: "Window click screenshot" },
        { category: "Screenshots", mod: "Super+Alt", key: "Print", desc: "Active monitor screenshot" },
        { category: "Screenshots", mod: "Super+Ctrl", key: "Print", desc: "Color picker" },
        { category: "Screenshots", mod: "Super+Shift", key: "T", desc: "OCR selection to clipboard" },

        { category: "Audio", mod: "", key: "XF86AudioMute", desc: "Toggle mute" },
        { category: "Audio", mod: "", key: "XF86AudioMicMute", desc: "Toggle mic mute" },
        { category: "Audio", mod: "", key: "XF86AudioLowerVolume", desc: "Volume down 5%" },
        { category: "Audio", mod: "", key: "XF86AudioRaiseVolume", desc: "Volume up 5%" },
        { category: "Audio", mod: "", key: "XF86AudioPlay", desc: "Media play" },
        { category: "Audio", mod: "", key: "XF86AudioPause", desc: "Media play/pause" },
        { category: "Audio", mod: "", key: "XF86AudioNext", desc: "Media next" },
        { category: "Audio", mod: "", key: "XF86AudioPrev", desc: "Media previous" },
        { category: "Audio", mod: "", key: "XF86AudioStop", desc: "Media stop" },

        { category: "Brightness", mod: "", key: "XF86MonBrightnessUp", desc: "Screen brightness +5%" },
        { category: "Brightness", mod: "", key: "XF86MonBrightnessDown", desc: "Screen brightness −5%" },
        { category: "Brightness", mod: "", key: "XF86KbdBrightnessUp", desc: "Keyboard brightness up" },
        { category: "Brightness", mod: "", key: "XF86KbdBrightnessDown", desc: "Keyboard brightness down" },

        { category: "ASUS ROG", mod: "", key: "XF86Launch4", desc: "Platform profile toggle (Fn+F5)" },
        { category: "ASUS ROG", mod: "", key: "XF86Launch3", desc: "Keyboard Aura mode cycle (Fn+F4)" },
        { category: "ASUS ROG", mod: "Super+Ctrl", key: "K", desc: "Keyboard RGB theme sync" },
        { category: "ASUS ROG", mod: "Super+Ctrl+Shift", key: "K", desc: "Keyboard LED off" },
        { category: "ASUS ROG", mod: "Super+Ctrl", key: "G", desc: "Hybrid GPU toggle" },
        { category: "ASUS ROG", mod: "Super+Ctrl", key: "B", desc: "Battery status notification" },
        { category: "ASUS ROG", mod: "", key: "XF86TouchpadToggle", desc: "Toggle touchpad (Fn+F10)" }
    ]

    property string searchText: ""

    readonly property var categories: {
        var cats = []
        var seen = {}
        for (var i = 0; i < allKeybinds.length; i++) {
            var cat = allKeybinds[i].category
            if (!seen[cat]) {
                seen[cat] = true
                cats.push(cat)
            }
        }
        return cats
    }

    readonly property var filteredKeybinds: {
        if (searchText === "") return allKeybinds
        var q = searchText.toLowerCase()
        return allKeybinds.filter(function(kb) {
            return kb.key.toLowerCase().includes(q)
                || kb.desc.toLowerCase().includes(q)
                || kb.mod.toLowerCase().includes(q)
                || kb.category.toLowerCase().includes(q)
        })
    }

    readonly property var filteredCategories: {
        var cats = []
        var seen = {}
        for (var i = 0; i < filteredKeybinds.length; i++) {
            var cat = filteredKeybinds[i].category
            if (!seen[cat]) {
                seen[cat] = true
                cats.push(cat)
            }
        }
        return cats
    }

    function keybindsForCategory(cat) {
        return filteredKeybinds.filter(function(kb) { return kb.category === cat })
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.closeKeybinds()
    }

    Rectangle {
        id: popupRect
        anchors.centerIn: parent
        width: 720
        height: 580
        radius: Appearance.popout.radius
        color: Theme.withAlpha(Theme.background, 0.95)

        MouseArea { anchors.fill: parent }

        FocusScope {
            id: keyHandler
            anchors.fill: parent
            focus: true

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    ShellState.closeKeybinds()
                    event.accepted = true
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: Appearance.popout.contentMargin
                spacing: 12

                Item {
                    width: parent.width
                    height: 32

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Keybinds"
                        color: Theme.surfaceText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: filteredKeybinds.length + " binds"
                        color: Theme.surfaceVariantText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 12
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
                                keybindsPopup.searchText = text
                                listFlickable.contentY = 0
                            }
                        }
                    }
                }

                Flickable {
                    id: listFlickable
                    width: parent.width
                    height: parent.height - 100
                    contentHeight: contentColumn.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: contentColumn
                        width: parent.width
                        spacing: 0

                        Repeater {
                            model: keybindsPopup.filteredCategories

                            delegate: Column {
                                required property string modelData
                                width: contentColumn.width
                                spacing: 0

                                property var catBinds: keybindsPopup.keybindsForCategory(modelData)

                                Item {
                                    width: parent.width
                                    height: 36

                                    Text {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData
                                        color: Theme.primary
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        font.letterSpacing: 1.2
                                        font.capitalization: Font.AllUppercase
                                    }

                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 120
                                        height: 1
                                        color: Theme.withAlpha(Theme.outline, 0.3)
                                    }
                                }

                                Repeater {
                                    model: catBinds

                                    delegate: Item {
                                        required property var modelData
                                        width: contentColumn.width
                                        height: 38

                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.leftMargin: -4
                                            anchors.rightMargin: -4
                                            radius: 6
                                            color: rowMouse.containsMouse
                                                ? Theme.withAlpha(Theme.surfaceVariant, 0.25)
                                                : "transparent"

                                            MouseArea {
                                                id: rowMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                            }
                                        }

                                        Row {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            spacing: 10

                                            Row {
                                                spacing: 4
                                                anchors.verticalCenter: parent.verticalCenter

                                                Repeater {
                                                    model: {
                                                        var parts = []
                                                        if (modelData.mod !== "") {
                                                            var mods = modelData.mod.split("+")
                                                            for (var i = 0; i < mods.length; i++) {
                                                                parts.push(mods[i])
                                                            }
                                                        }
                                                        parts.push(modelData.key)
                                                        return parts
                                                    }

                                                    delegate: Rectangle {
                                                        required property string modelData
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        height: 22
                                                        width: keyLabel.implicitWidth + 12
                                                        radius: 5
                                                        color: Theme.withAlpha(Theme.primary, 0.15)
                                                        border.color: Theme.withAlpha(Theme.primary, 0.3)
                                                        border.width: 1

                                                        Text {
                                                            id: keyLabel
                                                            anchors.centerIn: parent
                                                            text: modelData
                                                            color: Theme.primary
                                                            font.family: Appearance.fontFamily
                                                            font.pixelSize: 11
                                                            font.weight: Font.Medium
                                                        }
                                                    }
                                                }
                                            }

                                            Text {
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData.desc
                                                color: Theme.surfaceText
                                                font.family: Appearance.fontFamily
                                                font.pixelSize: 13
                                                elide: Text.ElideRight
                                                width: contentColumn.width - 220
                                            }
                                        }
                                    }
                                }

                                Item { width: 1; height: 4 }
                            }
                        }

                        Text {
                            visible: keybindsPopup.filteredKeybinds.length === 0
                            anchors.horizontalCenter: parent.horizontalCenter
                            topPadding: 80
                            text: "No matching keybinds"
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
                keybindsPopup.searchText = ""
                listFlickable.contentY = 0
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
