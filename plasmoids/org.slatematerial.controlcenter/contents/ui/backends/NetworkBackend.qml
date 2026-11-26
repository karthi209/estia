import QtQuick
import org.kde.plasma.networkmanagement as NM
import org.kde.plasma.workspace.dbus as DBus

QtObject {
    id: root
    property Component networkModel: Component {
        NM.AppletProxyModel { sourceModel: NM.NetworkModel {} }
    }

    function createNetworkModel(owner) {
        return networkModel.createObject(owner)
    }
    readonly property bool networkAvailable: devices.wiredDeviceAvailable || hasWifi || primaryActive
    readonly property bool hasWifi: devices.wirelessDeviceAvailable
    readonly property bool wifiEnabled: enabledConnections.wirelessEnabled
    readonly property bool canEnable: hasWifi && enabledConnections.wirelessHwEnabled
        && enabledConnections.networkingEnabled
    readonly property bool scanning: handler.scanning
    property string error: ""

    readonly property string primaryPath: manager.properties.PrimaryConnection?.toString() ?? "/"
    readonly property bool primaryActive: primary.properties.State?.value === 2
    readonly property string primaryType: primaryActive ? manager.properties.PrimaryConnectionType ?? "" : ""
    readonly property bool wiredConnected: primaryType === "802-3-ethernet"
    readonly property string connectionStatus: wiredConnected ? qsTr("Ethernet connected")
        : primaryType === "802-11-wireless" ? primary.properties.Id || qsTr("Wi-Fi connected")
        : !hasWifi ? qsTr("Unavailable") : wifiEnabled ? qsTr("On") : qsTr("Off")

    property DBus.Properties manager: DBus.Properties {
        busType: DBus.BusType.System
        service: "org.freedesktop.NetworkManager"
        path: "/org/freedesktop/NetworkManager"
        iface: "org.freedesktop.NetworkManager"
    }

    property DBus.Properties primary: DBus.Properties {
        busType: DBus.BusType.System
        service: "org.freedesktop.NetworkManager"
        path: root.primaryPath === "/" ? "" : root.primaryPath
        iface: "org.freedesktop.NetworkManager.Connection.Active"
    }

    function scan() {
        if (canEnable && wifiEnabled && !scanning) {
            error = ""
            handler.requestScan()
        }
    }

    function setWifi(enabled) {
        if (canEnable)
            handler.enableWireless(enabled)
    }

    function describe(row) {
        const wireless = row.Type === NM.Enums.Wireless
        const saved = !!row.ConnectionPath && row.ConnectionPath !== "/"
        const open = row.SecurityType === NM.Enums.NoneSecurity
        const personal = [NM.Enums.WpaPsk, NM.Enums.Wpa2Psk, NM.Enums.SAE].includes(row.SecurityType)
        return {
            wireless, saved, open, personal,
            name: row.Name, icon: row.ConnectionIcon,
            device: row.DevicePath, accessPoint: row.SpecificPath, profile: row.ConnectionPath,
            connected: row.ConnectionState === NM.Enums.Activated,
            connecting: row.ConnectionState === NM.Enums.Activating
        }
    }

    function connectNetwork(network, password) {
        if (!wifiEnabled || !network || !network.wireless || !network.device
            || network.connected || network.connecting)
            return
        error = ""
        if (network.saved)
            handler.activateConnection(network.profile, network.device, network.accessPoint)
        else if ((network.open || (network.personal && password)) && network.accessPoint)
            handler.addAndActivateConnection(network.device, network.accessPoint, password)
    }

    property NM.AvailableDevices devices: NM.AvailableDevices {}
    property NM.EnabledConnections enabledConnections: NM.EnabledConnections {}
    property NM.Handler handler: NM.Handler {
        onConnectionActivationFailed: (path, message) => root.error = message || qsTr("Could not connect")
    }
}
