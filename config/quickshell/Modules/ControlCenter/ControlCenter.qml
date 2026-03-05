import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services

PanelWindow {
    id: ccWindow

    visible: ShellState.controlCenterOpen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: ShellState.controlCenterOpen
        ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell:control-center"

    anchors { top: true; left: true; right: true; bottom: true }
    color: "transparent"

    Connections {
        target: ShellState
        function onControlCenterOpenChanged() {
            if (ShellState.controlCenterOpen && ShellState.activeTab === "cc") {
                NetworkService.scanWifi()
                NetworkService.refreshVpnList()
                NetworkService.checkWifiEnabled()
            }
            if (!ShellState.controlCenterOpen) {
                NetworkService.cancelPassword()
            }
        }
        function onActiveTabChanged() {
            if (ShellState.controlCenterOpen && ShellState.activeTab === "cc") {
                NetworkService.scanWifi()
                NetworkService.refreshVpnList()
                NetworkService.checkWifiEnabled()
            }
        }
    }

    readonly property string volumeIcon: {
        if (AudioService.sinkMuted) return "\uDB81\uDF5F"
        if (AudioService.sinkVolume <= 0) return "\uDB81\uDD7F"
        if (AudioService.sinkVolume < 50) return "\uDB81\uDD80"
        return "\uDB81\uDD7E"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.closeControlCenter()
    }

    Rectangle {
        id: popupRect

        x: {
            if (ShellState.ccTriggerWidth === 0)
                return (ccWindow.width - Appearance.popout.ccWidth) / 2
            var center = ShellState.ccTriggerX + ShellState.ccTriggerWidth / 2
            var rawX = center - Appearance.popout.ccWidth / 2
            return Math.max(Appearance.popout.gap,
                Math.min(rawX, ccWindow.width - Appearance.popout.ccWidth - Appearance.popout.gap))
        }
        y: ccWindow.height - Appearance.barHeight - height
        width: Appearance.popout.ccWidth
        height: Math.min(
            popupInner.implicitHeight + Appearance.popout.contentMargin * 2,
            ccWindow.height - Appearance.barHeight
        )

        radius: Appearance.popout.radius
        color: Theme.withAlpha(Theme.background, 0.95)

        MouseArea { anchors.fill: parent }

        Flickable {
            anchors.fill: parent
            anchors.margins: Appearance.popout.contentMargin
            contentHeight: popupInner.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: popupInner
                width: parent.width
                spacing: 12

                    Row {
                    id: tabStrip
                    width: parent.width
                    spacing: 6

                    readonly property real tabWidth: (width - spacing * 2) / 3

                    Rectangle {
                        width: tabStrip.tabWidth
                        height: 28
                        radius: 8
                        color: ShellState.activeTab === "cc"
                            ? Theme.primary
                            : Theme.withAlpha(Theme.surfaceVariant, 0.4)

                        Behavior on color {
                            enabled: SettingsService.animationsEnabled
                            ColorAnimation { duration: Appearance.anim.quick }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Controls"
                            color: ShellState.activeTab === "cc" ? Theme.primaryText : Theme.surfaceVariantText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Bold

                            Behavior on color {
                                enabled: SettingsService.animationsEnabled
                                ColorAnimation { duration: Appearance.anim.quick }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ShellState.activeTab = "cc"
                        }
                    }

                    Rectangle {
                        width: tabStrip.tabWidth
                        height: 28
                        radius: 8
                        color: ShellState.activeTab === "wallpaper"
                            ? Theme.primary
                            : Theme.withAlpha(Theme.surfaceVariant, 0.4)

                        Behavior on color {
                            enabled: SettingsService.animationsEnabled
                            ColorAnimation { duration: Appearance.anim.quick }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Wallpaper"
                            color: ShellState.activeTab === "wallpaper" ? Theme.primaryText : Theme.surfaceVariantText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Bold

                            Behavior on color {
                                enabled: SettingsService.animationsEnabled
                                ColorAnimation { duration: Appearance.anim.quick }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ShellState.activeTab = "wallpaper"
                        }
                    }

                    Rectangle {
                        width: tabStrip.tabWidth
                        height: 28
                        radius: 8
                        color: ShellState.activeTab === "settings"
                            ? Theme.primary
                            : Theme.withAlpha(Theme.surfaceVariant, 0.4)

                        Behavior on color {
                            enabled: SettingsService.animationsEnabled
                            ColorAnimation { duration: Appearance.anim.quick }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Settings"
                            color: ShellState.activeTab === "settings" ? Theme.primaryText : Theme.surfaceVariantText
                            font.family: Appearance.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Bold

                            Behavior on color {
                                enabled: SettingsService.animationsEnabled
                                ColorAnimation { duration: Appearance.anim.quick }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ShellState.activeTab = "settings"
                        }
                    }
                }

                Item {
                    width: parent.width
                    implicitHeight: {
                        if (ShellState.activeTab === "wallpaper")
                            return Math.max(ccTabContent.implicitHeight, wallpaperLoader.item ? wallpaperLoader.item.implicitHeight : 0)
                        if (ShellState.activeTab === "settings")
                            return Math.max(ccTabContent.implicitHeight, settingsLoader.item ? settingsLoader.item.implicitHeight : 0)
                        return ccTabContent.implicitHeight
                    }

                    Column {
                        id: ccTabContent
                        width: parent.width
                        spacing: 12
                        visible: ShellState.activeTab === "cc"

                        Row {
                            width: parent.width

                            Text {
                                text: "Control Center"
                                color: Theme.surfaceText
                                font.family: Appearance.fontFamily
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                width: parent.width - closeBtnCC.width
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                id: closeBtnCC
                                width: closeLabelCC.implicitWidth + 16
                                height: closeLabelCC.implicitHeight + 8
                                radius: 6
                                color: closeMouseCC.containsMouse
                                    ? Theme.withAlpha(Theme.error, 0.2)
                                    : Theme.withAlpha(Theme.surfaceVariant, 0.2)
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    id: closeLabelCC
                                    anchors.centerIn: parent
                                    text: "\u2715"
                                    color: closeMouseCC.containsMouse ? Theme.error : Theme.surfaceVariantText
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }

                                MouseArea {
                                    id: closeMouseCC
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: ShellState.closeControlCenter()
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.withAlpha(Theme.outline, 0.15)
                        }

                        Grid {
                            id: tileGrid
                            columns: 2
                            columnSpacing: 8
                            rowSpacing: 8
                            width: parent.width

                            readonly property real tileWidth: (width - columnSpacing) / 2

                            ToggleTile {
                                width: tileGrid.tileWidth
                                label: "WiFi"
                                sublabel: {
                                    if (!NetworkService.wifiEnabled) return "Off"
                                    if (NetworkService.connectionType === "wifi" && NetworkService.wifiSSID)
                                        return NetworkService.wifiSSID
                                    return "Disconnected"
                                }
                                icon: "\uDB82\uDD28"
                                active: NetworkService.wifiEnabled
                                hasDetail: true
                                onToggled: NetworkService.toggleWifiRadio()
                                onDetailRequested: ShellState.toggleDetail("wifi")
                            }

                            ToggleTile {
                                width: tileGrid.tileWidth
                                label: "Bluetooth"
                                sublabel: {
                                    if (!BluetoothService.enabled) return "Off"
                                    if (BluetoothService.connectedCount > 0)
                                        return BluetoothService.connectedCount + " connected"
                                    return "On"
                                }
                                icon: BluetoothService.icon
                                active: BluetoothService.enabled
                                hasDetail: true
                                onToggled: BluetoothService.toggleBluetooth()
                                onDetailRequested: ShellState.toggleDetail("bluetooth")
                            }

                            ToggleTile {
                                width: tileGrid.tileWidth
                                label: "Night Light"
                                sublabel: NightLightService.active ? "On" : "Off"
                                icon: "\uDB80\uDD89"
                                active: NightLightService.active
                                onToggled: NightLightService.toggle()
                            }

                            ToggleTile {
                                width: tileGrid.tileWidth
                                label: "Do Not Disturb"
                                sublabel: ShellState.dndEnabled ? "On" : "Off"
                                icon: "\uDB80\uDC9B"
                                active: ShellState.dndEnabled
                                onToggled: ShellState.toggleDnd()
                            }

                            ToggleTile {
                                width: tileGrid.tileWidth
                                label: "Audio Output"
                                sublabel: AudioService.sinkMuted ? "Muted" : AudioService.sinkName || "Unknown"
                                icon: ccWindow.volumeIcon
                                active: !AudioService.sinkMuted
                                hasDetail: true
                                onToggled: AudioService.toggleSinkMute()
                                onDetailRequested: ShellState.toggleDetail("audio")
                            }

                            ToggleTile {
                                width: tileGrid.tileWidth
                                label: "Game Mode"
                                sublabel: SettingsService.gameModeEnabled ? "On" : "Off"
                                icon: "\uDB80\uDC8E"
                                active: SettingsService.gameModeEnabled
                                onToggled: SettingsService.setGameMode(!SettingsService.gameModeEnabled)
                            }
                        }

                        Item {
                            id: detailContainer
                            width: parent.width
                            height: ShellState.expandedDetail !== "" && detailLoader.item
                                ? detailLoader.item.implicitHeight + 24 : 0
                            clip: true
                            visible: height > 0

                            Behavior on height {
                                enabled: SettingsService.animationsEnabled
                                NumberAnimation { duration: Appearance.anim.normal; easing.type: Easing.OutCubic }
                            }

                            Rectangle {
                                width: parent.width
                                height: detailLoader.item
                                    ? detailLoader.item.implicitHeight + 24 : 0
                                radius: 12
                                color: Theme.withAlpha(Theme.surface, 0.3)

                                Loader {
                                    id: detailLoader
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: 12
                                    y: 12
                                    active: ShellState.expandedDetail !== ""
                                    sourceComponent: {
                                        switch (ShellState.expandedDetail) {
                                        case "wifi": return wifiDetailComp
                                        case "bluetooth": return btDetailComp
                                        case "audio": return audioDetailComp
                                        default: return null
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            implicitHeight: volSlider.implicitHeight + 16
                            radius: 12
                            color: Theme.withAlpha(Theme.surface, 0.3)

                            SliderControl {
                                id: volSlider
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 12
                                value: AudioService.sinkVolume
                                icon: ccWindow.volumeIcon
                                muted: AudioService.sinkMuted
                                onSliderMoved: newValue => AudioService.setSinkVolume(newValue)
                                onIconClicked: AudioService.toggleSinkMute()
                            }
                        }

                        Rectangle {
                            width: parent.width
                            implicitHeight: micSlider.implicitHeight + 16
                            radius: 12
                            color: Theme.withAlpha(Theme.surface, 0.3)

                            SliderControl {
                                id: micSlider
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 12
                                value: AudioService.sourceVolume
                                icon: AudioService.sourceIcon
                                muted: AudioService.sourceMuted
                                onSliderMoved: newValue => AudioService.setSourceVolume(newValue)
                                onIconClicked: AudioService.toggleSourceMute()
                            }
                        }

                        Rectangle {
                            width: parent.width
                            implicitHeight: brightSlider.implicitHeight + 16
                            radius: 12
                            color: Theme.withAlpha(Theme.surface, 0.3)

                            SliderControl {
                                id: brightSlider
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 12
                                value: BrightnessService.brightness
                                icon: "\uDB80\uDCE0"
                                onSliderMoved: newValue => BrightnessService.setBrightness(newValue)
                            }
                        }

                        VpnSection { width: parent.width }
                    }

                    Loader {
                        id: wallpaperLoader
                        width: parent.width
                        active: ShellState.activeTab === "wallpaper"
                        visible: active
                        sourceComponent: wallpaperComp
                        onLoaded: item.width = Qt.binding(function() { return wallpaperLoader.width })
                    }

                    Loader {
                        id: settingsLoader
                        width: parent.width
                        active: ShellState.activeTab === "settings"
                        visible: active
                        sourceComponent: settingsComp
                        onLoaded: item.width = Qt.binding(function() { return settingsLoader.width })
                    }
                }
            }
        }
    }

    Component {
        id: wifiDetailComp
        WiFiSection {}
    }

    Component {
        id: btDetailComp
        BluetoothSection {}
    }

    Component {
        id: audioDetailComp
        AudioOutputSection {}
    }

    Component {
        id: wallpaperComp
        WallpaperSection {}
    }

    Component {
        id: settingsComp
        SettingsSection {}
    }

    Item {
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                ShellState.closeControlCenter()
                event.accepted = true
            }
        }
    }
}
