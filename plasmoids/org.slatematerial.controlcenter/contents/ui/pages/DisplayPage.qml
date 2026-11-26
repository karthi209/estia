import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import "../components"

ColumnLayout {
    id: root
    required property var brightness
    spacing: 8
    readonly property var controllableMonitors: brightness?.monitors.filter(monitor => monitor.available) ?? []
    signal closeRequested()
    signal settingsRequested()

    RowLayout {
        visible: !details.active
        Layout.fillWidth: true
        SlateButton {
            text: qsTr("Back")
            onClicked: root.closeRequested()
        }
        Controls.Label {
            text: qsTr("Display")
            Layout.fillWidth: true
        }
    }

    Controls.Label {
        visible: !details.active
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        text: root.controllableMonitors.length
            ? qsTr("Monitor brightness")
            : qsTr("KDE reports no brightness-controllable monitors")
    }

    Controls.ScrollView {
        id: scroll
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(rows.implicitHeight, 220)
        visible: !details.active && rows.implicitHeight > 0
        contentWidth: availableWidth
        contentHeight: rows.implicitHeight
        clip: true

        ColumnLayout {
            id: rows
            width: scroll.availableWidth
            spacing: 8

            Repeater {
                model: root.controllableMonitors
                PillSlider {
                    required property var modelData
                    Layout.fillWidth: true
                    accessibleName: qsTr("Brightness for %1").arg(subtitle)
                    iconName: "display-brightness-symbolic"
                    subtitle: modelData.label || modelData.displayName
                    value: modelData.value
                    minimumValue: root.brightness.minimumPercent
                    enabled: modelData.available
                    onValueEdited: percent => modelData.setBrightness(percent)
                }
            }
        }
    }

    function closeDetails() {
        details.active = false
        detailsButton.forceActiveFocus(Qt.BacktabFocusReason)
    }

    Loader {
        id: details
        active: false
        Layout.fillWidth: true
        source: "DisplayDetails.qml"
        focus: active
        onLoaded: item.forceActiveFocus()
        Keys.onEscapePressed: root.closeDetails()
        onStatusChanged: if (status === Loader.Error) {
            active = false
            root.settingsRequested()
        }
    }

    Connections {
        target: details.item
        function onCloseRequested() { root.closeDetails() }
        function onSettingsRequested() { root.settingsRequested() }
    }

    SlateButton {
        id: detailsButton
        visible: !details.active
        text: qsTr("Modes, scale and layout")
        onClicked: details.active = true
    }

    SlateButton {
        visible: !details.active
        text: qsTr("Configure displays")
        onClicked: root.settingsRequested()
    }
}
