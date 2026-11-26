import QtQuick
import org.kde.plasma.workspace.dbus as DBus

QtObject {
    readonly property bool available: watcher.registered

    function openHistory(opened, failed) {
        if (!available)
            return
        DBus.SessionBus.asyncCall({
            service: watcher.watchedService,
            path: "/klipper",
            iface: "org.kde.klipper.klipper",
            member: "showKlipperPopupMenu"
        }, opened, failed)
    }

    property DBus.DBusServiceWatcher watcher: DBus.DBusServiceWatcher {
        watchedService: "org.kde.klipper"
    }
}
