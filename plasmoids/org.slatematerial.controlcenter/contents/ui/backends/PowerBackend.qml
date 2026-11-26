import QtQuick
import org.kde.plasma.private.batterymonitor as Power

QtObject {
    readonly property var profiles: control.profiles
    readonly property string activeProfile: control.activeProfile
    readonly property string error: control.profileError
    readonly property string limitation: control.inhibitionReason

    function profileLabel(profile) {
        switch (profile) {
        case "power-saver": return qsTr("Power Saver")
        case "balanced": return qsTr("Balanced")
        case "performance": return qsTr("Performance")
        default: return profile
        }
    }

    function select(profile) {
        if (profiles.includes(profile) && profile !== activeProfile)
            control.setProfile(profile)
    }

    property Power.PowerProfilesControl control: Power.PowerProfilesControl {}
}
