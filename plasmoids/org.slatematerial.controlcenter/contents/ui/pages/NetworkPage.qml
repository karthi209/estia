import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import "../components"
import "../design" as Design

ColumnLayout {
    id: root
    spacing: 8
    signal closeRequested()
    signal settingsRequested()
    property var selectedNetwork: null

    function networkIcon(name) {
        const strength = /(?:signal-|wireless-)(none|weak|ok|good|excellent|0|25|50|75|100)(?:[-_]|$)/.exec(name ?? "")
        const levels = { none: "weak", 0: "weak", 25: "weak", 50: "ok", 75: "good", 100: "good", excellent: "good" }
        const symbol = strength ? "network-wireless-signal-" + (levels[strength[1]] ?? strength[1])
            : "network-wireless"
        return symbol + "-symbolic"
    }

    required property var backend
    property var networks: null
    Component.onCompleted: backend.scan()

    RowLayout {
        Layout.fillWidth: true
        SlateButton {
            text: qsTr("Back")
            onClicked: root.closeRequested()
        }
        Controls.Label {
            text: backend.hasWifi ? qsTr("Wi-Fi") : qsTr("Network")
            font.bold: true
            Layout.fillWidth: true
        }
        Controls.Switch {
            text: qsTr("Wi-Fi")
            visible: backend.hasWifi
            enabled: backend.canEnable
            onClicked: backend.setWifi(!backend.wifiEnabled)
            Binding on checked { value: backend.wifiEnabled }
        }
    }

    RowLayout {
        visible: backend.wiredConnected
        Layout.fillWidth: true
        spacing: 8

        SymbolicIcon {
            iconName: "network-wired-symbolic"
            color: Design.SlateDark.text
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
        }
        Controls.Label {
            Layout.fillWidth: true
            text: qsTr("Ethernet connected")
            font.bold: true
        }
    }

    Controls.Label {
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        visible: backend.hasWifi || !backend.wiredConnected
        text: !backend.hasWifi ? (backend.primaryActive ? backend.connectionStatus : qsTr("No active connection"))
            : !backend.canEnable ? qsTr("Wi-Fi unavailable")
            : !backend.wifiEnabled ? qsTr("Wi-Fi is off")
            : backend.scanning ? qsTr("Scanning…") : backend.primaryActive && !backend.wiredConnected ? backend.connectionStatus : qsTr("Select a nearby network")
    }

    ListView {
        id: listing
        readonly property real scrollGutter: Math.max(10, wifiScrollbar.width) + 4
        Layout.fillWidth: true
        Layout.preferredHeight: 190
        spacing: 4
        visible: backend.wifiEnabled && backend.hasWifi
        clip: true
        model: visible ? root.networks : null
        onVisibleChanged: {
            if (visible && !root.networks)
                root.networks = backend.createNetworkModel(root)
        }
        Component.onCompleted: {
            if (visible && !root.networks)
                root.networks = backend.createNetworkModel(root)
        }
        Controls.ScrollBar.vertical: Controls.ScrollBar {
            id: wifiScrollbar
            policy: Controls.ScrollBar.AsNeeded
        }
        delegate: DetailRow {
            id: entry
            required property var model
            readonly property var network: backend.describe(model)
            width: Math.max(0, listing.width - listing.scrollGutter)
            x: listing.effectiveLayoutDirection === Qt.RightToLeft ? listing.scrollGutter : 0
            visible: network.wireless
            height: visible ? implicitHeight : 0
            enabled: visible && !network.connecting
            title: network.name
            selected: network.connected
            description: selected ? qsTr("Connected") : network.connecting ? qsTr("Connecting…")
                : network.saved ? qsTr("Saved network") : network.open ? qsTr("Open network") : qsTr("Secured network")
            actionLabel: selected || network.connecting ? "" : qsTr("Connect")
            symbol: root.networkIcon(network.icon)
            actionOnly: true
            onActionRequested: {
                if (network.connected || network.connecting)
                    return
                if (network.saved || network.open)
                    backend.connectNetwork(network, "")
                else if (network.personal) {
                    password.clear()
                    root.selectedNetwork = network
                    password.forceActiveFocus()
                } else {
                    root.settingsRequested()
                }
            }
        }
    }

    Controls.TextField {
        id: password
        Layout.fillWidth: true
        visible: root.selectedNetwork !== null
        placeholderText: root.selectedNetwork
            ? qsTr("Password for %1").arg(root.selectedNetwork.name) : ""
        echoMode: TextInput.Password
        onAccepted: join.clicked()
    }

    Controls.Label {
        Layout.fillWidth: true
        visible: backend.error.length > 0
        text: backend.error
        wrapMode: Text.Wrap
    }

    RowLayout {
        SlateButton {
            id: join
            text: qsTr("Connect")
            visible: password.visible
            enabled: password.text.length > 0 && backend.wifiEnabled
            onClicked: {
                if (!enabled)
                    return
                backend.connectNetwork(root.selectedNetwork, password.text)
                password.clear()
                root.selectedNetwork = null
            }
        }
        SlateButton {
            visible: backend.hasWifi
            text: qsTr("Scan")
            enabled: backend.hasWifi && backend.wifiEnabled && !backend.scanning
            onClicked: backend.scan()
        }
        SlateButton {
            text: qsTr("Network Settings")
            onClicked: root.settingsRequested()
        }
    }
}
