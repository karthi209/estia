import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import "../design" as Design
import "../backends"
import "../components"

ColumnLayout {
    id: root
    spacing: 8
    signal closeRequested()
    signal settingsRequested()

    DisplayInfo { id: info }
    Component.onCompleted: info.refresh()

    RowLayout {
        Layout.fillWidth: true
        SlateButton {
            text: qsTr("Back")
            onClicked: root.closeRequested()
        }
        Controls.Label {
            Layout.fillWidth: true
            text: qsTr("Display modes and layout")
        }
        SlateButton {
            text: qsTr("Refresh")
            enabled: !info.loading
            onClicked: info.refresh()
        }
    }

    Controls.Label {
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        visible: info.loading || info.error.length > 0 || !info.outputs.length
        text: info.loading ? qsTr("Reading displays…") : info.error || qsTr("No connected displays")
    }

    Controls.ScrollView {
        id: scroll
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(rows.implicitHeight, 250)
        visible: info.outputs.length > 0
        contentWidth: availableWidth
        contentHeight: rows.implicitHeight
        clip: true
        ColumnLayout {
            id: rows
            width: scroll.availableWidth
            Repeater {
                model: info.outputs
                Rectangle {
                    id: card
                    required property var modelData
                    readonly property var modes: modelData.modes ?? []
                    readonly property var currentMode: modes.find(mode => mode.id === modelData.currentModeId)
                    readonly property var facts: [
                        { label: qsTr("Scale"), value: Number.isFinite(modelData.scale)
                            ? qsTr("%1%").arg(Math.round(modelData.scale * 100)) : "" },
                        { label: qsTr("Position"), value: modelData.pos
                            ? qsTr("%1, %2").arg(modelData.pos.x).arg(modelData.pos.y) : "" },
                        { label: qsTr("Rotation"), value: modelData.rotation === 1 ? qsTr("Normal")
                            : modelData.rotation === 2 ? qsTr("Left")
                            : modelData.rotation === 4 ? qsTr("Inverted")
                            : modelData.rotation === 8 ? qsTr("Right") : "" },
                        { label: qsTr("HDR"), value: typeof modelData.hdr === "boolean"
                            ? (modelData.hdr ? qsTr("On") : qsTr("Off")) : "" },
                        { label: qsTr("Variable refresh"), value: modelData.vrrPolicy === 0 ? qsTr("Never")
                            : modelData.vrrPolicy === 1 ? qsTr("Always")
                            : modelData.vrrPolicy === 2 ? qsTr("Automatic") : "" }
                    ].filter(fact => fact.value !== "")

                    Layout.fillWidth: true
                    implicitHeight: fields.implicitHeight + 24
                    radius: 14
                    color: Design.SlateDark.surface

                    ColumnLayout {
                        id: fields
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6

                        Controls.Label {
                            text: card.modelData.name
                            font.bold: true
                        }
                        Controls.Label {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: !card.modelData.enabled ? qsTr("Disabled") : card.currentMode
                                ? qsTr("%1 × %2 at %3 Hz").arg(card.currentMode.size.width)
                                    .arg(card.currentMode.size.height)
                                    .arg(card.currentMode.refreshRate.toLocaleString(Qt.locale(), "f", 2))
                                : qsTr("Active mode unavailable")
                        }
                        Repeater {
                            model: card.modelData.enabled ? card.facts : []
                            RowLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                Controls.Label {
                                    Layout.fillWidth: true
                                    text: modelData.label
                                    color: Design.SlateDark.secondaryText
                                }
                                Controls.Label { text: modelData.value }
                            }
                        }
                        Controls.ComboBox {
                            Layout.fillWidth: true
                            visible: card.modes.length > 0
                            Accessible.name: qsTr("Supported modes for %1").arg(card.modelData.name)
                            model: card.modes.map(mode => qsTr("%1 × %2 at %3 Hz")
                                .arg(mode.size.width).arg(mode.size.height)
                                .arg(mode.refreshRate.toLocaleString(Qt.locale(), "f", 2)))
                            displayText: qsTr("Browse supported modes")
                        }
                    }
                }
            }
        }
    }

    SlateButton {
        text: qsTr("Change in KDE Display Configuration")
        onClicked: root.settingsRequested()
    }
}
