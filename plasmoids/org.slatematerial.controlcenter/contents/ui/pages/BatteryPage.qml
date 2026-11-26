import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import "../components"
import "../design" as Design

ColumnLayout {
    id: root
    required property var battery
    signal closeRequested()
    signal settingsRequested()
    spacing: 10

    RowLayout {
        SlateButton {
            text: qsTr("Back")
            onClicked: root.closeRequested()
        }
        Controls.Label {
            text: qsTr("Battery")
            font.bold: true
        }
    }
    Controls.Label {
        text: battery.available ? qsTr("%1 · %2").arg(battery.level).arg(battery.status) : qsTr("No battery present")
    }
    Controls.ProgressBar {
        Layout.fillWidth: true
        visible: battery.available
        from: 0
        to: 100
        value: battery.percentage
        Accessible.name: qsTr("Battery charge")
        palette.highlight: Design.SlateDark.accent
    }
}
