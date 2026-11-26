import QtQuick
import org.kde.plasma.workspace.dbus as DBus

QtObject {
    readonly property bool available: watcher.registered && display.properties.IsPresent === true
    readonly property real percentage: display.properties.Percentage?.value ?? 0
    readonly property int state: display.properties.State?.value ?? 0
    readonly property string status: {
        switch (state) {
        case 1: return qsTr("Charging")
        case 2: return qsTr("Discharging")
        case 3: return qsTr("Empty")
        case 4: return qsTr("Fully charged")
        case 5: return qsTr("Waiting to charge")
        case 6: return qsTr("Waiting to discharge")
        default: return qsTr("Power status unknown")
        }
    }
    readonly property string level: qsTr("%1%").arg(Math.round(percentage))

    property DBus.DBusServiceWatcher watcher: DBus.DBusServiceWatcher {
        busType: DBus.BusType.System
        watchedService: "org.freedesktop.UPower"
    }

    property DBus.Properties display: DBus.Properties {
        busType: DBus.BusType.System
        service: "org.freedesktop.UPower"
        path: "/org/freedesktop/UPower/devices/DisplayDevice"
        iface: "org.freedesktop.UPower.Device"
    }
}
