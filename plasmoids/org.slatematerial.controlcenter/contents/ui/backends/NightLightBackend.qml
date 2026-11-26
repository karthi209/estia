import QtQuick
import org.kde.plasma.workspace.dbus as DBus
import org.kde.plasma.private.brightnesscontrolplugin as Native

QtObject {
    readonly property bool available: state.properties.available === true
    readonly property bool enabled: state.properties.enabled === true
    readonly property bool running: state.properties.running === true
    readonly property bool paused: state.properties.inhibited === true
    readonly property bool pausedByControl: Native.NightLightInhibitor.inhibited
    readonly property int temperature: state.properties.currentTemperature?.value ?? 0

    function preview(temperature, onError) {
        if (!available || !Number.isFinite(temperature))
            return
        DBus.SessionBus.asyncCall({
            service: state.service, path: state.path, iface: state.iface,
            member: "preview", signature: "u",
            arguments: [DBus.uint32(Math.round(temperature))]
        }, () => {}, onError)
    }

    function stopPreview() {
        DBus.SessionBus.asyncCall({
            service: state.service, path: state.path, iface: state.iface,
            member: "stopPreview"
        })
    }

    function togglePause() {
        if (available && (enabled || pausedByControl) && (!paused || pausedByControl))
            Native.NightLightInhibitor.toggleInhibition()
    }

    property DBus.Properties state: DBus.Properties {
        service: "org.kde.KWin.NightLight"
        path: "/org/kde/KWin/NightLight"
        iface: "org.kde.KWin.NightLight"
    }
}
