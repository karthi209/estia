import QtQuick
import "design" as Design
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid
import "components"

PlasmoidItem {
    id: root

    activationTogglesExpanded: true
    onExpandedChanged: {
        if (root.expanded)
            Qt.callLater(() => {
                if (root.expanded)
                    root.fullRepresentationItem?.openHome()
            })
    }

    preferredRepresentation: compactRepresentation

    readonly property bool bluetoothOn: !!bluetoothLoader.item?.powered && !bluetoothLoader.item?.blocked
    readonly property bool quietOn: !!notificationLoader.item?.quiet
    readonly property bool awakeOn: !!keepAwakeLoader.item?.active
    readonly property bool nightLightOn: !!nightLightLoader.item?.running && !nightLightLoader.item?.paused
        && nightLightLoader.item.temperature > 0 && nightLightLoader.item.temperature < 6500
    readonly property int compactWidth: 60 + 24 * (
        Number(bluetoothOn) + Number(quietOn) + Number(awakeOn) + Number(nightLightOn))
    readonly property var activeDescriptions: [
        networkLoader.item?.description ?? "",
        audioLoader.item?.deviceName ?? "",
        bluetoothOn ? qsTr("Bluetooth on") : "",
        quietOn ? qsTr("Do Not Disturb on") : "",
        awakeOn ? qsTr("Keep Awake on") : "",
        nightLightOn ? qsTr("Night Light active") : ""
    ].filter(Boolean)

    toolTipMainText: qsTr("Estia")
    toolTipSubText: activeDescriptions.join(" · ")

    Loader {
        id: networkLoader
        asynchronous: true
        source: "backends/PanelNetworkStatus.qml"
    }

    Loader {
        id: bluetoothLoader
        asynchronous: true
        source: "backends/BluetoothBackend.qml"
    }

    Loader {
        id: notificationLoader
        asynchronous: true
        source: "backends/NotificationBackend.qml"
    }

    Loader {
        id: keepAwakeLoader
        asynchronous: true
        source: "backends/KeepAwakeBackend.qml"
    }

    Loader {
        id: nightLightLoader
        asynchronous: true
        source: "backends/NightLightBackend.qml"
    }

    // The panel allocates space from Layout hints, not just implicitWidth.
    Layout.minimumWidth: root.compactWidth
    Layout.preferredWidth: root.compactWidth
    Layout.fillWidth: false

    Loader {
        id: audioLoader
        source: "backends/AudioBackend.qml"
    }

    compactRepresentation: Controls.AbstractButton {
        id: compact
        implicitWidth: root.compactWidth
        implicitHeight: 32

        Layout.minimumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth
        Layout.maximumWidth: implicitWidth
        Layout.fillWidth: false

        property bool wasExpanded: false
        Accessible.name: qsTr("Estia")
        Accessible.description: root.toolTipSubText
        onPressed: wasExpanded = root.expanded

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: height / 2
            color: compact.hovered || compact.visualFocus
                ? Design.SlateDark.hover
                : "transparent"
            Behavior on color { ColorAnimation { duration: 100 } }
        }

        RowLayout {
            id: statusIcons
            anchors.centerIn: parent
            spacing: 7

            Repeater {
                model: [
                    "network",
                    "audio",
                    "bluetooth",
                    "quiet",
                    "awake",
                    "night"
                ]

                SymbolicIcon {
                    visible: {
                        switch (modelData) {
                        case "bluetooth": return root.bluetoothOn
                        case "quiet": return root.quietOn
                        case "awake": return root.awakeOn
                        case "night": return root.nightLightOn
                        default: return true
                        }
                    }
                    iconName: {
                        switch (modelData) {
                        case "network":
                            return networkLoader.item?.iconName ?? "network-offline-symbolic"
                        case "audio":
                            return audioLoader.item?.iconName ?? "audio-volume-muted-symbolic"
                        case "bluetooth":
                            return "bluetooth-symbolic"
                        case "quiet":
                            return "notifications-disabled-symbolic"
                        case "awake":
                            return "keep-awake-symbolic"
                        default:
                            return "night-light-symbolic"
                        }
                    }
                    color: Design.SlateDark.text
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                    Layout.minimumWidth: 18
                    Layout.maximumWidth: 18
                    Layout.minimumHeight: 18
                    Layout.maximumHeight: 18
                }
            }
        }

        onClicked: root.expanded = !wasExpanded
    }

    fullRepresentation: ControlCenter {
        audio: audioLoader.item
        bluetoothBackend: bluetoothLoader.item
        notifications: notificationLoader.item
        keepAwake: keepAwakeLoader.item
        nightLight: nightLightLoader.item
        onDismissRequested: root.expanded = false
        tilePreferences: Plasmoid.configuration.tiles
        onTilePreferencesEdited: value => Plasmoid.configuration.tiles = value
        Layout.minimumWidth: Design.SlateDark.popupWidth
        Layout.preferredWidth: Design.SlateDark.popupWidth
        Layout.maximumWidth: Design.SlateDark.popupWidth
        Layout.minimumHeight: implicitHeight
        Layout.preferredHeight: implicitHeight
        Layout.maximumHeight: implicitHeight
    }
}
