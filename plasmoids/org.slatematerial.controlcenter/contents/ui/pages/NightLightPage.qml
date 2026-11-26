import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window
import "../design" as Design
import "../components"

ColumnLayout {
    id: root
    spacing: 8
    signal closeRequested()
    signal settingsRequested()
    required property var nightLight

    readonly property bool presenting: visible && (Window.window?.visible ?? true)
    property bool previewing: false
    property int previewRequest: 0
    property string previewError: ""

    function endPreview() {
        previewDelay.stop()
        ++previewRequest
        if (previewing) {
            previewing = false
            previewExpiry.stop()
            nightLight.stopPreview()
        }
    }

    function startPreview() {
        if (!presenting || !nightLight.available)
            return
        const request = ++previewRequest
        root.previewError = ""
        root.previewing = true
        previewExpiry.restart()
        nightLight.preview(root.previewTemperature, () => {
            if (request !== root.previewRequest)
                return
            root.previewing = false
            previewExpiry.stop()
            root.previewError = qsTr("Could not start temperature preview.")
        })
    }

    Timer {
        id: previewDelay
        interval: 120
        onTriggered: root.startPreview()
    }

    onPresentingChanged: if (!presenting) endPreview()
    Component.onDestruction: endPreview()

    Timer {
        id: previewExpiry
        interval: 15000
        onTriggered: root.endPreview()
    }

    RowLayout {
        Layout.fillWidth: true
        SlateButton {
            text: qsTr("Back")
            onClicked: root.closeRequested()
        }
        Controls.Label {
            Layout.fillWidth: true
            text: qsTr("Night Light")
            font.bold: true
        }
    }
    Controls.Label {
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        text: !nightLight.available ? qsTr("Night Light unavailable")
            : nightLight.paused ? qsTr("Night Light paused")
            : !nightLight.enabled ? qsTr("Night Light disabled in Settings")
            : nightLight.running ? qsTr("Night Light active · %1 K").arg(nightLight.temperature)
            : qsTr("Night Light is waiting for its schedule")
    }
    property int previewTemperature: Math.max(1000, Math.min(6500, nightLight.temperature || 6500))

    PillSlider {
        Layout.fillWidth: true
        iconName: "night-light-symbolic"
        accessibleName: qsTr("Preview temperature in kelvin")
        subtitle: qsTr("Temperature preview")
        minimumValue: 1000
        maximumValue: 6500
        stepSize: 100
        valueSuffix: " K"
        value: root.previewTemperature
        enabled: nightLight.available
        onValueEdited: kelvin => {
            root.previewTemperature = kelvin
            previewDelay.restart()
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Controls.Label {
            Layout.fillWidth: true
            text: qsTr("Warmer")
        }
        Controls.Label { text: qsTr("Cooler") }
    }

    RowLayout {
        Layout.fillWidth: true
        SlateButton {
            text: qsTr("Stop preview")
            visible: root.previewing || previewDelay.running
            onClicked: root.endPreview()
        }
        Controls.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: root.previewError || qsTr("Moving the slider previews the color for 15 seconds. Save changes in KDE Settings.")
            color: Design.SlateDark.secondaryText
        }
    }

    SlateButton {
        text: nightLight.pausedByControl ? qsTr("Resume Night Light") : qsTr("Pause Night Light")
        enabled: nightLight.available && (nightLight.enabled || nightLight.pausedByControl)
            && (!nightLight.paused || nightLight.pausedByControl)
        onClicked: nightLight.togglePause()
    }
    SlateButton {
        text: qsTr("Schedule and temperature settings")
        onClicked: root.settingsRequested()
    }
}
