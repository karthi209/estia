import QtQuick
import "../design" as Design
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"

ColumnLayout {
    id: root
    required property var audio
    property bool expanded: false
    required property Item trigger
    signal mixerRequested(Item trigger)
    spacing: 6
    visible: expanded && !!audio

    Binding {
        target: root.audio
        property: "outputListRequested"
        value: root.visible && (root.Window.window?.visible ?? true)
        when: !!root.audio
    }

    function focusOutput(index) {
        if (!expanded || devices.count === 0)
            return
        const row = Math.max(0, Math.min(devices.count - 1, index))
        devices.positionViewAtIndex(row, ListView.Contain)
        devices.forceLayout()
        devices.itemAtIndex(row)?.forceActiveFocus(Qt.TabFocusReason)
    }

    function collapse() {
        expanded = false
        root.trigger.forceActiveFocus(Qt.BacktabFocusReason)
    }

    Rectangle {
        visible: root.expanded
        Layout.fillWidth: true
        implicitHeight: Math.max(48, Math.min(devices.contentHeight + 12, 184))
        radius: 16
        color: Design.SlateDark.surface
        ListView {
            id: devices
            objectName: "audioOutputsList"
            anchors.fill: parent
            anchors.margins: 6
            clip: true
            model: root.expanded ? root.audio?.outputs ?? null : null
            spacing: 2
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentHeight > height
            Controls.ScrollBar.vertical: Controls.ScrollBar {
                policy: Controls.ScrollBar.AsNeeded
            }
            delegate: Controls.AbstractButton {
                id: deviceButton
                required property var model
                required property int index
                readonly property var device: model.PulseObject
                width: ListView.view.width
                height: 46
                leftPadding: 10
                rightPadding: 10
                readonly property bool selected: !!device?.default
                enabled: !!device
                Keys.onDownPressed: root.focusOutput(index + 1)
                Keys.onUpPressed: {
                    if (index === 0)
                        root.trigger.forceActiveFocus(Qt.BacktabFocusReason)
                    else
                        root.focusOutput(index - 1)
                }
                Keys.onEscapePressed: root.collapse()
                Accessible.name: device?.description ?? ""
                Accessible.description: selected ? qsTr("Current output") : qsTr("Select as default output")
                Controls.ToolTip.text: Accessible.name
                Controls.ToolTip.visible: hovered && deviceName.truncated
                onClicked: root.audio.selectOutput(device)
                background: Rectangle {
                    radius: 12
                    color: deviceButton.selected ? Design.SlateDark.selection
                        : deviceButton.down || deviceButton.hovered ? Design.SlateDark.hover : "transparent"
                    border.width: deviceButton.visualFocus ? 1 : 0
                    border.color: Design.SlateDark.accent
                }
                contentItem: RowLayout {
                    spacing: 8
                    SymbolicIcon {
                        iconName: "audio-card-symbolic"
                        color: Design.SlateDark.secondaryText
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 18
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            id: deviceName
                            text: deviceButton.device?.description ?? ""
                            color: Design.SlateDark.text
                            font.pixelSize: Design.SlateDark.bodySize
                            font.weight: deviceButton.selected ? Font.DemiBold : Font.Normal
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Text {
                            visible: text.length > 0
                            text: deviceButton.device?.virtualDevice ? qsTr("Virtual output") : ""
                            color: Design.SlateDark.secondaryText
                            font.pixelSize: Design.SlateDark.annotationSize
                        }
                    }
                    SymbolicIcon {
                        opacity: deviceButton.selected ? 1 : 0
                        iconName: "selection-check-symbolic"
                        color: Design.SlateDark.text
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                    }
                }
            }
        }
        Text {
            anchors.centerIn: parent
            visible: devices.count === 0
            text: qsTr("No audio outputs")
            color: Design.SlateDark.secondaryText
            font.pixelSize: Design.SlateDark.labelSize
        }
    }
    Text {
        visible: microphone.visible
        Layout.topMargin: 3
        text: qsTr("Microphone")
        color: Design.SlateDark.text
        font.pixelSize: Design.SlateDark.labelSize
        font.weight: Font.DemiBold
    }

    PillSlider {
        id: microphone
        visible: root.visible && !!root.audio?.microphoneAvailable
        Layout.fillWidth: true
        accessibleName: qsTr("Microphone")
        iconName: muted ? "microphone-sensitivity-muted-symbolic" : "microphone-sensitivity-high-symbolic"
        subtitle: root.audio?.microphoneName ?? ""
        value: root.audio?.microphoneVolume ?? 0
        editable: !!root.audio?.microphoneWritable
        muted: !!root.audio?.microphoneMuted
        iconClickable: !!root.audio?.microphoneAvailable
        onValueEdited: value => root.audio?.setMicrophoneVolume(value)
        onIconClicked: root.audio?.toggleMicrophoneMute()
    }

    SlateButton {
        id: mixerButton
        objectName: "mixerButton"
        text: qsTr("Application volume")
        onClicked: root.mixerRequested(mixerButton)
    }
}
