import QtQuick
import org.kde.kcmutils as KCM

QtObject {
    function openSettings(module) {
        KCM.KCMLauncher.openSystemSettings(module)
    }
}
