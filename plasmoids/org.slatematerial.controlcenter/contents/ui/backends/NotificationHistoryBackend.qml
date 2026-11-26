import QtQuick
import org.kde.notificationmanager as Native

Native.Notifications {
    showExpired: true
    showDismissed: true
    showAddedDuringInhibition: true
    showJobs: false
    groupMode: Native.Notifications.GroupDisabled
    sortMode: Native.Notifications.SortByDate
    sortOrder: Qt.DescendingOrder
    limit: 40
}
