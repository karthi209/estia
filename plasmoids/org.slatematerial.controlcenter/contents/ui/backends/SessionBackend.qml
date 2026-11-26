import QtQuick
import org.kde.kworkspace as Workspace

QtObject {
    readonly property bool canLock: session.canLock
    readonly property bool canOpenMenu: session.canLogout || session.canShutdown || session.canReboot

    function lock() {
        if (canLock)
            session.lock()
    }

    function powerMenu() {
        if (canOpenMenu)
            session.requestLogoutPrompt()
    }

    property Workspace.SessionManagement session: Workspace.SessionManagement {}
}
