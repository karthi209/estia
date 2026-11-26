import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"
import "../design" as Design

ColumnLayout {
    id: root
    required property var media
    signal closeRequested()
    signal settingsRequested()
    spacing: 10

    property real elapsed: media.position
    function timeText(value) {
        const seconds = Math.floor(value / 1000000)
        return Math.floor(seconds / 60) + ":" + String(seconds % 60).padStart(2, "0")
    }

    Connections {
        target: root.media
        function onPositionChanged() { root.elapsed = root.media.position }
        function onPlayerChanged() { root.elapsed = root.media.position }
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.visible && (root.Window.window?.visible ?? true)
            && root.media.playing && root.media.length > 0
        onTriggered: root.elapsed = Math.min(root.media.length, root.elapsed + 1000000)
    }

    SlateButton {
        text: qsTr("Back")
        onClicked: root.closeRequested()
    }

    Controls.Label {
        Layout.fillWidth: true
        text: media.available ? media.title : qsTr("No controllable media player")
        elide: Text.ElideRight
        font.bold: true
    }

    Controls.Label {
        Layout.fillWidth: true
        visible: media.available && text.length > 0
        text: media.artist
        elide: Text.ElideRight
    }

    Controls.Slider {
        id: seekBar
        Layout.preferredHeight: 26
        Layout.fillWidth: true
        visible: root.media.length > 0
        enabled: root.media.canSeek
        from: 0
        to: root.media.length
        property real pendingSeek: -1
        padding: 0
        Accessible.name: qsTr("Playback position")
        Binding on value {
            value: root.elapsed
            when: !seekBar.pressed
            restoreMode: Binding.RestoreNone
        }
        function commitSeek(target) {
            root.elapsed = target
            root.media.seek(target)
        }
        onMoved: {
            if (pressed)
                pendingSeek = value
            else
                commitSeek(value)
        }
        onPressedChanged: {
            if (!pressed && pendingSeek >= 0) {
                if (enabled)
                    commitSeek(pendingSeek)
                pendingSeek = -1
            }
        }
        background: Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 6
            radius: 3
            color: Design.SlateDark.hover
            Rectangle {
                width: seekBar.position * parent.width
                height: parent.height
                radius: parent.radius
                color: Design.SlateDark.accent
            }
        }
        handle: Item { width: 0; height: 0 }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: seekBar.visible
        Controls.Label {
            text: root.timeText(seekBar.pressed ? seekBar.position * seekBar.to : root.elapsed)
            Layout.fillWidth: true
        }
        Controls.Label { text: root.timeText(root.media.length) }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        visible: root.media.available
        spacing: 8
        Repeater {
            model: [
                { icon: "media-previous-symbolic", label: qsTr("Previous"), allowed: root.media.canGoPrevious, action: () => root.media.previous() },
                { icon: root.media.playing ? "media-pause-symbolic" : "media-play-symbolic", label: root.media.playing ? qsTr("Pause") : qsTr("Play"), allowed: root.media.canToggle, action: () => root.media.toggle() },
                { icon: "media-next-symbolic", label: qsTr("Next"), allowed: root.media.canGoNext, action: () => root.media.next() }
            ]
            SlateButton {
                required property var modelData
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                enabled: modelData.allowed
                padding: 7
                Accessible.name: modelData.label
                Controls.ToolTip.text: modelData.label
                Controls.ToolTip.visible: hovered
                contentItem: SymbolicIcon {
                    iconName: modelData.icon
                    color: Design.SlateDark.text
                    opacity: parent.enabled ? 1 : 0.45
                }
                onClicked: modelData.action()
            }
        }
    }
}
