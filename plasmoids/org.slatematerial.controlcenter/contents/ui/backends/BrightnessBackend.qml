import QtQuick
import org.kde.plasma.private.brightnesscontrolplugin as Native

Item {
    id: root
    visible: false

    readonly property int minimumPercent: 5
    property var monitors: []
    readonly property var display: monitors.length === 1 ? monitors[0] : null
    readonly property bool available: !!display && display.available
    readonly property real actualValue: available ? display.actualValue : 0
    readonly property real value: available ? display.value : 0
    readonly property string label: available ? display.label : qsTr("Brightness unavailable")

    function refreshDisplays() {
        const current = []
        for (let index = 0; index < displays.count; ++index) {
            const monitor = displays.objectAt(index)
            if (monitor)
                current.push(monitor)
        }
        monitors = current
    }

    function setBrightness(percent) {
        if (available)
            display.setBrightness(percent)
    }

    Native.ScreenBrightnessControl { id: control }

    Instantiator {
        id: displays
        model: control.displays
        delegate: QtObject {
            id: monitor
            required property string displayName
            required property string label
            required property int brightness
            required property int maxBrightness
            property bool attached: true
            readonly property bool available: attached && control.isBrightnessAvailable && maxBrightness > 0
            readonly property real actualValue: available ? Math.round(brightness / maxBrightness * 100) : 0
            readonly property real value: available && updates.pending
                ? Math.round(updates.value / maxBrightness * 100) : actualValue

            function setBrightness(percent) {
                if (!available || !Number.isFinite(percent))
                    return
                const bounded = Math.max(root.minimumPercent, Math.min(100, percent))
                updates.schedule(monitor, displayName, Math.round(bounded / 100 * maxBrightness))
            }

            onAvailableChanged: if (!available) updates.cancel()
            onDisplayNameChanged: updates.cancel()

            property HardwareUpdateQueue updates: HardwareUpdateQueue {
                id: updates
                onDispatched: (device, key, requested) => {
                    if (monitor.available && device === monitor && key === monitor.displayName) {
                        const minimum = Math.ceil(root.minimumPercent / 100 * monitor.maxBrightness)
                        control.setBrightness(key, Math.max(minimum, Math.min(monitor.maxBrightness, requested)))
                    }
                }
            }
        }
        onObjectAdded: Qt.callLater(root.refreshDisplays)
        onObjectRemoved: (index, object) => {
            object.attached = false
            root.monitors = root.monitors.filter(monitor => monitor !== object)
            Qt.callLater(root.refreshDisplays)
        }
    }
}
