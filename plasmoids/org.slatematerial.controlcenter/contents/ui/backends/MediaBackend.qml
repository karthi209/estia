import QtQuick
import org.kde.plasma.private.mpris as Mpris

QtObject {
    readonly property var player: players.currentPlayer
    readonly property bool available: !!player && player.canControl
    readonly property bool playing: player?.playbackStatus === Mpris.PlaybackStatus.Playing
    readonly property string title: player?.track || player?.identity || qsTr("Media")
    readonly property string artist: player?.artist || ""
    readonly property bool canToggle: available && (playing ? player.canPause : player.canPlay)
    readonly property bool canGoPrevious: available && player.canGoPrevious
    readonly property bool canGoNext: available && player.canGoNext

    readonly property real length: Math.max(0, player?.length ?? 0)
    readonly property real position: Math.max(0, player?.position ?? 0)
    readonly property bool canSeek: available && !!player.canSeek && length > 0

    function seek(target) {
        if (canSeek && Number.isFinite(target))
            player.position = Math.round(Math.min(length, Math.max(0, target)))
    }

    function toggle() {
        if (!canToggle)
            return
        if (playing)
            player.Pause()
        else
            player.Play()
    }

    function previous() {
        if (canGoPrevious)
            player.Previous()
    }

    function next() {
        if (canGoNext)
            player.Next()
    }

    property Mpris.Mpris2Model players: Mpris.Mpris2Model {}
}
