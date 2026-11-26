import QtQuick

// Coalesce bursts without postponing writes indefinitely during a continuous drag.
QtObject {
    id: root
    property int interval: 100
    readonly property bool pending: timer.running
    property var target: null
    property string key: ""
    property int value: 0
    signal dispatched(var device, string deviceKey, int hardwareValue)

    function schedule(device, deviceKey, hardwareValue) {
        target = device
        key = deviceKey
        value = hardwareValue
        if (!timer.running)
            timer.start()
    }

    function cancel() {
        timer.stop()
        target = null
        key = ""
    }

    property Timer timer: Timer {
        interval: root.interval
        repeat: false
        onTriggered: {
            const device = root.target
            const deviceKey = root.key
            const hardwareValue = root.value
            root.target = null
            root.key = ""
            root.dispatched(device, deviceKey, hardwareValue)
        }
    }
}
