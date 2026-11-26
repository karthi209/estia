import QtQuick
import org.kde.plasma.workspace.dbus as DBus

DBus.Properties {
    busType: DBus.BusType.System
    service: "org.freedesktop.NetworkManager"
    path: "/org/freedesktop/NetworkManager"
    iface: "org.freedesktop.NetworkManager"

    readonly property string connectionType: properties.PrimaryConnectionType ?? ""
    readonly property bool wired: connectionType === "802-3-ethernet"
    readonly property bool wireless: connectionType === "802-11-wireless"
    readonly property bool connected: connectionType.length > 0
    readonly property string iconName: wired ? "network-wired-symbolic"
        : wireless ? "network-wireless-symbolic"
        : connected ? "network-transmit-receive-symbolic" : "network-offline-symbolic"
    readonly property string description: wired ? qsTr("Ethernet connected")
        : wireless ? qsTr("Wi-Fi connected")
        : connected ? qsTr("Network connected") : qsTr("No primary network connection")
}
