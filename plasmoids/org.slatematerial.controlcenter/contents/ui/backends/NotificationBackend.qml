import QtQuick
import org.kde.notificationmanager as Notifications

QtObject {
    id: root

    readonly property bool timedQuiet: quietExpiry.running
    readonly property bool quiet: timedQuiet || notificationSettings.notificationsInhibitedByApplication
    readonly property string quietStatus: timedQuiet ? qsTr("On")
        : quiet ? qsTr("On · requested by an app") : qsTr("Off")

    signal settingsRequested()

    function toggleQuiet() {
        if (!timedQuiet && quiet) {
            settingsRequested()
            return
        }
        notificationSettings.notificationsInhibitedUntil = timedQuiet
            ? new Date(0) : new Date(Date.now() + 3600000)
        notificationSettings.save()
        syncExpiry()
    }

    function syncExpiry() {
        const remaining = notificationSettings.notificationsInhibitedUntil.getTime() - Date.now()
        quietExpiry.stop()
        if (remaining > 0) {
            quietExpiry.interval = Math.min(remaining, 2147483647)
            quietExpiry.start()
        }
    }

    property Notifications.Settings notificationSettings: Notifications.Settings {
        onSettingsChanged: root.syncExpiry()
    }
    property Timer quietExpiry: Timer {
        onTriggered: root.syncExpiry()
    }
    Component.onCompleted: syncExpiry()
}
