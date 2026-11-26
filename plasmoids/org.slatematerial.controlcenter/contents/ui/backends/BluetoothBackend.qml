import QtQuick
import org.kde.bluezqt as Bluez

QtObject {
    id: root

    readonly property var manager: Bluez.Manager
    readonly property var adapter: manager.usableAdapter || manager.adapters[0] || null
    readonly property bool blocked: manager.bluetoothBlocked
    readonly property bool canToggle: !!adapter && !busy
    readonly property bool powered: !!adapter && adapter.powered
    readonly property int connectedCount: manager.connectedDevices.length
    readonly property var devices: Bluez.Manager.devices
    readonly property bool busy: !!pending || powerTimeout.running
    property bool requestedPower: false
    property string error: ""
    property var pending: null

    function setPowered(enabled) {
        if (!canToggle || (enabled === powered && !blocked))
            return

        error = ""
        requestedPower = enabled
        powerTimeout.start()
        if (enabled && blocked)
            manager.bluetoothBlocked = false
        else
            adapter.powered = enabled
    }

    onBlockedChanged: {
        if (!blocked && powerTimeout.running && requestedPower && adapter)
            adapter.powered = true
    }

    onPoweredChanged: {
        if (powerTimeout.running && requestedPower === powered)
            powerTimeout.stop()
    }

    onAdapterChanged: {
        if (!adapter && powerTimeout.running) {
            powerTimeout.stop()
            error = qsTr("Bluetooth adapter disconnected.")
        }
    }

    property Timer powerTimeout: Timer {
        interval: 4000
        onTriggered: root.error = root.blocked
            ? qsTr("Bluetooth is blocked. Check the airplane mode or hardware switch.")
            : qsTr("The Bluetooth adapter did not change power state.")
    }

    function toggleDevice(device) {
        if (!powered || busy || !device || !device.paired || device.adapter !== adapter)
            return

        error = ""
        pending = device.connected ? device.disconnectFromDevice() : device.connectToDevice()
        if (!pending)
            error = qsTr("Bluetooth could not start the request.")
    }

    property Connections reply: Connections {
        target: root.pending
        function onFinished(call) {
            const result = call || root.pending
            if (result && result.error)
                root.error = result.errorText || qsTr("Bluetooth request failed.")
            root.pending = null
        }
    }
}
