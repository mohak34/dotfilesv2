import QtQuick
import qs.Common
import qs.Services

Column {
    id: root
    spacing: 6
    width: parent?.width ?? 0

    Text {
        visible: !NetworkService.wifiEnabled && !NetworkService.wifiToggling
        text: "Turn on WiFi to see available networks"
        color: Theme.surfaceVariantText
        font.family: Appearance.fontFamily
        font.pixelSize: 11
    }

    Text {
        visible: NetworkService.wifiToggling
        text: NetworkService.wifiEnabled ? "Disabling WiFi..." : "Enabling WiFi..."
        color: Theme.surfaceVariantText
        font.family: Appearance.fontFamily
        font.pixelSize: 11
    }

    Rectangle {
        visible: NetworkService.needsPassword
        width: parent.width
        height: passwordColumn.implicitHeight + 16
        radius: 8
        color: Theme.withAlpha(Theme.primary, 0.1)

        Column {
            id: passwordColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 8
            y: 8
            spacing: 6

            Text {
                text: "Connect to \"" + NetworkService.passwordSSID + "\""
                color: Theme.surfaceText
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
            }

            Row {
                width: parent.width
                spacing: 6

                Rectangle {
                    width: parent.width - pwConnectBtn.width - pwCancelBtn.width - 12
                    height: 26
                    radius: 4
                    color: Theme.withAlpha(Theme.surface, 0.8)
                    border.width: 1
                    border.color: Theme.withAlpha(Theme.outline, 0.3)

                    TextInput {
                        id: passwordInput
                        anchors.fill: parent
                        anchors.margins: 4
                        color: Theme.surfaceText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 11
                        echoMode: TextInput.Password
                        clip: true

                        Keys.onReturnPressed: {
                            if (text.length > 0)
                                NetworkService.connectWithPassword(
                                    NetworkService.passwordSSID, text)
                        }

                        onVisibleChanged: {
                            if (visible) {
                                text = ""
                                forceActiveFocus()
                            }
                        }
                    }
                }
                Rectangle {
                    id: pwConnectBtn
                    width: pwConnectLabel.implicitWidth + 14
                    height: 26
                    radius: 4
                    color: pwConnectMouse.containsMouse
                        ? Theme.withAlpha(Theme.primary, 0.8)
                        : Theme.primary

                    Text {
                        id: pwConnectLabel
                        anchors.centerIn: parent
                        text: "Go"
                        color: Theme.primaryText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: pwConnectMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (passwordInput.text.length > 0)
                                NetworkService.connectWithPassword(
                                    NetworkService.passwordSSID, passwordInput.text)
                        }
                    }
                }

                Rectangle {
                    id: pwCancelBtn
                    width: pwCancelLabel.implicitWidth + 14
                    height: 26
                    radius: 4
                    color: pwCancelMouse.containsMouse
                        ? Theme.withAlpha(Theme.error, 0.2)
                        : Theme.withAlpha(Theme.surfaceVariant, 0.3)

                    Text {
                        id: pwCancelLabel
                        anchors.centerIn: parent
                        text: "\u2715"
                        color: Theme.surfaceText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: pwCancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NetworkService.cancelPassword()
                    }
                }
            }
        }
    }

    Text {
        visible: NetworkService.connectionStatus === "auth_failed"
        text: "Authentication failed"
        color: Theme.error
        font.family: Appearance.fontFamily
        font.pixelSize: 10
    }

    Text {
        visible: NetworkService.isScanning && NetworkService.wifiNetworks.length === 0
        text: "Scanning..."
        color: Theme.surfaceVariantText
        font.family: Appearance.fontFamily
        font.pixelSize: 11
    }

    Flickable {
        width: parent.width
        height: Math.min(netCol.implicitHeight, 250)
        contentHeight: netCol.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        visible: !NetworkService.wifiToggling

        Column {
            id: netCol
            width: parent.width
            spacing: 2

            Repeater {
                model: NetworkService.wifiNetworks

            delegate: Rectangle {
                id: netDelegate

                required property var modelData
                required property int index
                width: netDelegate.parent?.width ?? 0
                height: 36
                radius: 6
                color: netMouse.containsMouse
                    ? Theme.withAlpha(Theme.surfaceVariant, 0.3)
                    : "transparent"

                readonly property bool isConnected: modelData.connected
                readonly property bool isSaved: modelData.saved
                readonly property bool isSecured: modelData.secured
                readonly property bool isConnecting:
                    NetworkService.connectingSSID === modelData.ssid

                readonly property string signalIcon: {
                    if (modelData.signal >= 67) return "\uDB82\uDD28"
                    if (modelData.signal >= 34) return "\uDB82\uDD25"
                    return "\uDB82\uDD22"
                }

                Text {
                    id: sigIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: netDelegate.signalIcon
                    color: netDelegate.isConnected ? Theme.primary : Theme.surfaceText
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize + 2
                }

                Text {
                    id: ssidText
                    anchors.left: sigIcon.right
                    anchors.leftMargin: 8
                    anchors.right: indicators.left
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: netDelegate.isConnecting ? modelData.ssid + "..." : modelData.ssid
                    color: netDelegate.isConnected ? Theme.primary
                        : netDelegate.isConnecting ? Theme.info
                        : Theme.surfaceText
                    font.family: Appearance.fontFamily
                    font.pixelSize: 11
                    font.weight: netDelegate.isConnected ? Font.Bold : Font.Normal
                    elide: Text.ElideRight
                }

                Row {
                    id: indicators
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        visible: netDelegate.isSaved && !netDelegate.isConnected
                        text: "\uDB81\uDCC0"
                        color: Theme.surfaceVariantText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        visible: netDelegate.isSecured
                        text: "\uDB80\uDF3E"
                        color: Theme.surfaceVariantText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: modelData.signal + "%"
                        color: Theme.surfaceVariantText
                        font.family: Appearance.fontFamily
                        font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: netMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (netDelegate.isConnected) return
                        if (netDelegate.isConnecting) return
                        if (netDelegate.isSecured && !netDelegate.isSaved) {
                            NetworkService.needsPassword = true
                            NetworkService.passwordSSID = modelData.ssid
                            NetworkService.connectionStatus = ""
                        } else {
                            NetworkService.connectToWifi(modelData.ssid)
                        }
                    }
                }
            }
        }
    }
    }

    Row {
        width: parent.width
        spacing: 8
        visible: !NetworkService.wifiToggling

        Rectangle {
            width: scanLabel.implicitWidth + 16
            height: scanLabel.implicitHeight + 8
            radius: 6
            color: scanMouse.containsMouse
                ? Theme.withAlpha(Theme.primary, 0.2)
                : Theme.withAlpha(Theme.surfaceVariant, 0.2)

            Text {
                id: scanLabel
                anchors.centerIn: parent
                text: NetworkService.isScanning ? "Scanning..." : "Scan"
                color: Theme.surfaceText
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
            }

            MouseArea {
                id: scanMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: NetworkService.isScanning ? Qt.ArrowCursor : Qt.PointingHandCursor
                enabled: !NetworkService.isScanning
                onClicked: NetworkService.scanWifi()
            }
        }

        Rectangle {
            visible: NetworkService.connected && NetworkService.connectionType === "wifi"
            width: disconnLabel.implicitWidth + 16
            height: disconnLabel.implicitHeight + 8
            radius: 6
            color: disconnMouse.containsMouse
                ? Theme.withAlpha(Theme.error, 0.2)
                : Theme.withAlpha(Theme.surfaceVariant, 0.2)

            Text {
                id: disconnLabel
                anchors.centerIn: parent
                text: "Disconnect"
                color: disconnMouse.containsMouse ? Theme.error : Theme.surfaceText
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
            }

            MouseArea {
                id: disconnMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NetworkService.disconnectWifi()
            }
        }

        Rectangle {
            visible: NetworkService.connected && NetworkService.connectionType === "wifi"
                && NetworkService._ssidToConnName[NetworkService.wifiSSID] !== undefined
            width: forgetLabel.implicitWidth + 16
            height: forgetLabel.implicitHeight + 8
            radius: 6
            color: forgetMouse.containsMouse
                ? Theme.withAlpha(Theme.error, 0.2)
                : Theme.withAlpha(Theme.surfaceVariant, 0.2)

            Text {
                id: forgetLabel
                anchors.centerIn: parent
                text: "Forget"
                color: forgetMouse.containsMouse ? Theme.error : Theme.surfaceText
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                font.weight: Font.Bold
            }

            MouseArea {
                id: forgetMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NetworkService.forgetWifi(NetworkService.wifiSSID)
            }
        }
    }
}
