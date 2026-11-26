import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import "../components"

ColumnLayout {
    id: root
    spacing: 8
    signal closeRequested()
    signal settingsRequested()

    required property var power

    RowLayout {
        Layout.fillWidth: true
        SlateButton {
            text: qsTr("Back")
            onClicked: root.closeRequested()
        }
        Controls.Label {
            Layout.fillWidth: true
            text: qsTr("Power Mode")
            font.bold: true
        }
    }

    Controls.Label {
        Layout.fillWidth: true
        text: power.activeProfile ? qsTr("Active profile: %1").arg(power.profileLabel(power.activeProfile))
            : qsTr("Power profiles unavailable")
        wrapMode: Text.WordWrap
    }

    Repeater {
        model: power.profiles
        DetailRow {
            required property string modelData
            Layout.fillWidth: true
            selected: modelData === power.activeProfile
            symbol: modelData === "performance" ? "performance-symbolic"
                : modelData === "power-saver" ? "power-saver-symbolic" : "power-profile-balanced-symbolic"
            title: power.profileLabel(modelData)
            description: modelData === "performance" ? qsTr("Prioritizes responsiveness")
                : modelData === "power-saver" ? qsTr("Reduces power use")
                : modelData === "balanced" ? qsTr("Balances speed and power use") : ""
            actionLabel: selected ? qsTr("Active") : ""
            onClicked: power.select(modelData)
        }
    }

    Controls.Label {
        Layout.fillWidth: true
        visible: text.length > 0
        wrapMode: Text.Wrap
        text: power.error || power.limitation
    }
    SlateButton {
        text: qsTr("Power Settings")
        onClicked: root.settingsRequested()
    }
}
