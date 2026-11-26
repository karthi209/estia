import QtQuick
import org.kde.plasma.plasma5support as Support
import org.kde.plasma.workspace.dbus as DBus

QtObject {
    id: root

    property bool activatable: false
    readonly property bool available: watcher.registered || activatable
    readonly property bool busy: screenshotLauncher.active
    property var lookup: null

    property DBus.DBusServiceWatcher watcher: DBus.DBusServiceWatcher {
        watchedService: "org.kde.spectacle"
    }

    Component.onCompleted: {
        lookup = DBus.SessionBus.asyncCall({
            service: "org.freedesktop.DBus",
            path: "/org/freedesktop/DBus",
            iface: "org.freedesktop.DBus",
            member: "ListActivatableNames"
        })
    }

    property Connections lookupReply: Connections {
        target: root.lookup
        function onFinished() {
            const names = root.lookup.value
            root.activatable = root.lookup.isValid && Array.from(names ?? []).some(
                name => name === "org.kde.spectacle" || name === "org.kde.Spectacle")
            root.lookup = null
        }
    }

    function openScreenshot(onOpened, onError) {
        if (!available || busy)
            return
        screenshotLauncher.onOpened = onOpened
        screenshotLauncher.onError = onError
        screenshotLauncher.active = true
    }

    property Loader screenshotLauncher: Loader {
        id: screenshotLauncher
        active: false
        property var onOpened
        property var onError
        sourceComponent: Support.DataSource {
            id: launcher
            readonly property string command: "spectacle --launchonly"
            engine: "executable"
            Component.onCompleted: connectSource(command)
            onNewData: (source, data) => {
                if (source !== command)
                    return
                disconnectSource(source)
                const finished = data["exit code"] === 0
                    ? screenshotLauncher.onOpened : screenshotLauncher.onError
                screenshotLauncher.active = false
                finished()
            }
        }
    }

}
