import QtQuick
import org.kde.plasma.workspace.dbus as DBus
import org.kde.plasma.private.batterymonitor as Power

QtObject {
    readonly property bool available: watcher.registered
    readonly property bool active: available && control.isManuallyInhibited
    readonly property string status: control.isManuallyInhibitedError
        ? qsTr("Could not change sleep inhibition") : active ? qsTr("On") : qsTr("Off")

    function toggle() {
        if (!available)
            return
        if (active)
            control.uninhibit()
        else
            control.inhibit(qsTr("Keep Awake enabled in Estia"))
    }

    property DBus.DBusServiceWatcher watcher: DBus.DBusServiceWatcher {
        watchedService: "org.kde.Solid.PowerManagement.PolicyAgent"
    }

    property Power.InhibitionControl control: Power.InhibitionControl {}
}
