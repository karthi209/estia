import QtQuick
import org.kde.plasma.private.volume as PulseAudio
import org.kde.kitemmodels as KItemModels

QtObject {
    readonly property int normalVolume: 65536
    readonly property var streams: PulseAudio.SinkInputModel {}
    readonly property int streamRole: streams.KItemModels.KRoleNames.role("PulseObject")

    function hasStream(stream) {
        if (!stream)
            return false
        for (let row = 0; row < streams.rowCount(); ++row) {
            if (streams.data(streams.index(row, 0), streamRole) === stream)
                return true
        }
        return false
    }

    function setVolume(stream, percent) {
        if (Number.isFinite(percent) && hasStream(stream) && stream.volumeWritable)
            stream.volume = Math.round(Math.max(0, Math.min(100, percent)) / 100 * normalVolume)
    }

    function toggleMute(stream) {
        if (hasStream(stream))
            stream.muted = !stream.muted
    }
}
