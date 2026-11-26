import QtQuick
import "../design" as Design
import QtQuick.Controls as Controls
import QtQuick.Layouts

RowLayout {
    id: root

    property string iconName: ""
    property string subtitle: ""
    property real value: 0
    property bool muted: false
    property bool iconClickable: false
    property bool editable: true
    property real minimumValue: 0
    property real maximumValue: 100
    property real stepSize: 1
    property string valueSuffix: "%"
    property string accessibleName: "Volume"

    signal valueEdited(real newValue)
    signal iconClicked()

    function focusSlider() {
        slider.forceActiveFocus(Qt.TabFocusReason)
    }

    spacing: 12

    Controls.AbstractButton {
        id: iconButton
        enabled: root.iconClickable
        Accessible.name: root.muted ? "Unmute " + root.accessibleName : "Mute " + root.accessibleName
        onClicked: root.iconClicked()
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32

        background: Rectangle {
            radius: 16
            color: iconButton.hovered || iconButton.activeFocus ? Design.SlateDark.hover : "transparent"
        }

        contentItem: SymbolicIcon {
            implicitWidth: 22
            implicitHeight: 22
            iconName: root.iconName
            color: Design.SlateDark.text
            opacity: root.muted ? 0.5 : 1.0
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        Controls.Slider {
            id: slider
            objectName: "slider"

            Layout.fillWidth: true
            Layout.preferredHeight: 32

            enabled: root.editable
            Accessible.name: root.accessibleName
            padding: 0
            from: root.minimumValue
            live: true
            touchDragThreshold: 0
            to: root.maximumValue
            stepSize: root.stepSize
            snapMode: Controls.Slider.SnapAlways

            onMoved: root.valueEdited(value)

            Binding {
                target: slider
                property: "value"
                value: root.value
                when: !slider.pressed
                restoreMode: Binding.RestoreNone
            }

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding
                    + (slider.availableHeight - height) / 2

                width: slider.availableWidth
                height: 22
                radius: 11
                color: Design.SlateDark.hover
                border.width: slider.visualFocus ? 1 : 0
                border.color: Design.SlateDark.accent

                Rectangle {
                    width: slider.position * parent.width
                    anchors.right: slider.mirrored ? parent.right : undefined
                    anchors.left: slider.mirrored ? undefined : parent.left
                    height: parent.height
                    radius: 11

                    color: root.muted
                        ? Design.SlateDark.mutedTrack
                        : Design.SlateDark.accent
                }
            }

            // A zero-width handle makes the native input range match the drawn track.
            handle: Item {
                width: 0
                height: 0
            }
        }

        Text {
            visible: root.subtitle.length > 0
            text: root.subtitle
            color: Design.SlateDark.secondaryText
            font.pixelSize: Design.SlateDark.captionSize

            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }

    Text {
        text: root.enabled ? Math.round(slider.value) + root.valueSuffix : "—"
        color: Design.SlateDark.secondaryText
        font.pixelSize: Design.SlateDark.labelSize
        Layout.preferredWidth: Math.max(34, implicitWidth)
        horizontalAlignment: Text.AlignRight
    }
}
