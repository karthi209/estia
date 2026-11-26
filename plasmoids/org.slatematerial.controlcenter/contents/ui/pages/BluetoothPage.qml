import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import "../components"

ColumnLayout {
    id: root
    spacing: 8
    signal closeRequested()
    signal settingsRequested()
    required property var backend

    RowLayout {
        Layout.fillWidth: true
        SlateButton {
            text: qsTr("Back")
            onClicked: root.closeRequested()
        }
        Controls.Label {
            Layout.fillWidth: true
            text: qsTr("Bluetooth")
            font.bold: true
        }
        Controls.Switch {
            Accessible.name: qsTr("Bluetooth power")
            enabled: backend.canToggle
            onClicked: backend.setPowered(!backend.powered)
            Binding on checked { value: backend.powered }
        }
    }

    Controls.Label {
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        text: !backend.adapter ? qsTr("No Bluetooth adapter available")
            : backend.blocked ? qsTr("Bluetooth radio is blocked")
            : !backend.powered ? qsTr("Bluetooth is off")
            : backend.connectedCount > 0 ? qsTr("%n connected device(s)", "", backend.connectedCount)
            : qsTr("Paired devices")
    }

    Controls.ScrollView {
        id: deviceScroll
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(deviceList.implicitHeight, 190)
        visible: backend.powered && deviceList.implicitHeight > 0
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            id: deviceList
            width: deviceScroll.availableWidth
            spacing: 4

            Repeater {
                model: backend.powered ? backend.devices : null
                DetailRow {
                    required property var modelData
                    Layout.fillWidth: true
                    visible: modelData.paired && modelData.adapter === backend.adapter
                    enabled: !backend.busy
                    title: modelData.name
                    symbol: "bluetooth-symbolic"
                    selected: modelData.connected
                    description: selected ? qsTr("Connected") : qsTr("Paired")
                    actionLabel: selected ? qsTr("Disconnect") : qsTr("Connect")
                    actionOnly: true
                    onActionRequested: backend.toggleDevice(modelData)
                }
            }
        }
    }

    Controls.Label {
        visible: backend.powered && deviceList.implicitHeight === 0
        text: qsTr("No paired devices on this adapter")
    }

    Controls.Label {
        Layout.fillWidth: true
        visible: backend.busy || backend.error.length > 0
        wrapMode: Text.Wrap
        text: backend.busy ? qsTr("Updating Bluetooth…") : backend.error
    }

    SlateButton {
        text: qsTr("Pair or manage devices")
        onClicked: root.settingsRequested()
    }
}
