import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import "../components"
import "../backends"

ColumnLayout {
    id: root
    spacing: 10
    signal closeRequested()
    signal settingsRequested()

    MixerBackend { id: mixer }

    RowLayout {
        SlateButton {
            text: qsTr("Back")
            onClicked: root.closeRequested()
        }
        Controls.Label {
            text: qsTr("Application volume")
        }
    }

    Controls.Label {
        visible: streams.count === 0
        text: qsTr("No applications are playing audio")
    }

    ListView {
        id: streams
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 230)
        visible: count > 0
        clip: true
        spacing: 6
        model: mixer.streams
        Controls.ScrollBar.vertical: Controls.ScrollBar {}
        delegate: PillSlider {
            required property var model
            readonly property var stream: model.PulseObject
            width: ListView.view.width - 10
            height: implicitHeight
            enabled: !!stream && model.HasVolume
            editable: !!stream && model.VolumeWritable
            iconClickable: enabled
            accessibleName: model.Name || qsTr("Application audio")
            subtitle: accessibleName
            iconName: model.Muted ? "audio-volume-muted-symbolic" : "audio-volume-high-symbolic"
            muted: !!model.Muted
            value: Math.round((model.Volume ?? 0) / mixer.normalVolume * 100)
            onValueEdited: percent => mixer.setVolume(stream, percent)
            onIconClicked: mixer.toggleMute(stream)
        }
    }
}
