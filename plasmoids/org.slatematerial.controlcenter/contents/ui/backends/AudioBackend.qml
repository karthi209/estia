import QtQuick
import org.kde.plasma.private.volume as PulseAudio
import org.kde.kitemmodels as KItemModels

QtObject {
    id: root

    property bool outputListRequested: false
    readonly property var outputs: outputLoader.item
    readonly property int outputRole: outputs ? outputs.KItemModels.KRoleNames.role("PulseObject") : -1

    property Loader outputLoader: Loader {
        active: root.outputListRequested
        sourceComponent: PulseAudio.SinkModel {}
    }

    // Only accept an object still present in the native model (hotplug safe).
    function selectOutput(device) {
        if (!device || !outputs || outputRole < 0)
            return false
        for (let row = 0; row < outputs.rowCount(); ++row) {
            if (outputs.data(outputs.index(row, 0), outputRole) === device) {
                device.default = true
                return true
            }
        }
        return false
    }

    readonly property var sink: PulseAudio.PreferredDevice.sink
    readonly property bool available: sink !== null && sink !== undefined

    // PulseAudio uses PA_VOLUME_NORM (0x10000) for 100%.
    readonly property int normalVolume: 65536
    readonly property bool volumeWritable: available && sink.volumeWritable

    readonly property real volume: available
        ? Math.round(sink.volume / normalVolume * 100)
        : 0

    readonly property bool muted: available ? sink.muted : false

    readonly property string deviceName: available
        ? sink.description
        : "No audio device"

    readonly property string iconName: muted || volume === 0
        ? "audio-volume-muted-symbolic"
        : volume <= 33
            ? "audio-volume-low-symbolic"
            : volume <= 66
                ? "audio-volume-medium-symbolic"
                : "audio-volume-high-symbolic"

    readonly property var microphone: PulseAudio.PreferredDevice.source
    readonly property bool microphoneAvailable: !!microphone
    readonly property bool microphoneWritable: microphoneAvailable && microphone.volumeWritable
    readonly property bool microphoneMuted: microphoneAvailable && microphone.muted
    readonly property real microphoneVolume: microphoneAvailable
        ? Math.round(microphone.volume / normalVolume * 100) : 0
    readonly property string microphoneName: microphoneAvailable
        ? microphone.description : qsTr("No microphone")

    function setMicrophoneVolume(percent) {
        if (microphoneWritable && Number.isFinite(percent))
            microphone.volume = Math.round(Math.max(0, Math.min(100, percent)) / 100 * normalVolume)
    }

    function toggleMicrophoneMute() {
        if (microphoneAvailable)
            microphone.muted = !microphone.muted
    }

    function setVolume(percent) {
        if (!volumeWritable || !Number.isFinite(percent))
            return

        const bounded = Math.max(0, Math.min(100, percent))
        sink.volume = Math.round(bounded / 100 * normalVolume)
    }

    function toggleMute() {
        if (available)
            sink.muted = !sink.muted
    }
}
