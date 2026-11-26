import QtQuick
import "design" as Design
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Window
import "components"
import "pages"

Rectangle {
    id: root

    color: Design.SlateDark.background
    // Native controls in the detail pages share the popup's dark color roles.
    palette.window: Design.SlateDark.background
    palette.windowText: Design.SlateDark.text
    palette.base: Design.SlateDark.surface
    palette.alternateBase: Design.SlateDark.background
    palette.text: Design.SlateDark.text
    palette.button: Design.SlateDark.surface
    palette.buttonText: Design.SlateDark.text
    palette.highlight: Design.SlateDark.accent
    palette.highlightedText: Design.SlateDark.accentText
    palette.placeholderText: Design.SlateDark.secondaryText
    radius: Design.SlateDark.popupRadius
    opacity: Window.window && !Window.window.visible ? 0 : 1
    Behavior on opacity { NumberAnimation { duration: 100 } }

    implicitWidth: Design.SlateDark.popupWidth
    implicitHeight: (pageLoader.status === Loader.Ready ? pageLoader.implicitHeight : content.implicitHeight) + 2 * Design.SlateDark.popupPadding
    property string pageModule: ""
    property string pageError: ""
    signal dismissRequested()

    function openHome() {
        pageModule = ""
        pageError = ""
        returnFocus = null
        audioDevices.expanded = false
        focusFirstControl()
    }

    function focusFirstControl() {
        if (pageLoader.item) {
            pageLoader.item.forceActiveFocus(Qt.TabFocusReason)
        } else if (volumeControl.enabled && volumeControl.editable) {
            volumeControl.focusSlider()
        } else if (outputButton.enabled) {
            outputButton.forceActiveFocus(Qt.TabFocusReason)
        } else {
            headerActions.itemAt(0)?.forceActiveFocus(Qt.TabFocusReason)
        }
    }
    property string tilePreferences: ""
    signal tilePreferencesEdited(string value)

    function orderedTiles(defaults) {
        let preferences
        try { preferences = JSON.parse(tilePreferences) } catch (error) { preferences = [] }
        if (!Array.isArray(preferences))
            preferences = []

        const remaining = defaults.slice()
        const result = []
        for (const preference of preferences) {
            const index = remaining.findIndex(tile => tile.key === preference?.key)
            if (index >= 0)
                result.push(Object.assign({}, remaining.splice(index, 1)[0], {hidden: preference.hidden === true}))
        }
        return result.concat(remaining)
    }
    readonly property var inlinePages: ({
        kcm_networkmanagement: "pages/NetworkPage.qml",
        kcm_bluetooth: "pages/BluetoothPage.qml",
        kcm_powerdevilprofilesconfig: "pages/PowerPage.qml",
        kcm_nightlight: "pages/NightLightPage.qml",
        kcm_kscreen: "pages/DisplayPage.qml",
        tiles: "pages/TileEditor.qml",
        mixer: "pages/MixerPage.qml",
        history: "pages/NotificationHistoryPage.qml",
        media: "pages/MediaPage.qml",
        battery: "pages/BatteryPage.qml"
    })

    Loader {
        id: wifi
        asynchronous: true
        source: "backends/NetworkBackend.qml"
    }

    property var bluetoothBackend: null
    property var notifications: null
    property var nightLight: null
    property var keepAwake: null

    Loader {
        id: power
        asynchronous: true
        source: "backends/PowerBackend.qml"
    }


    Loader {
        id: battery
        asynchronous: true
        source: "backends/BatteryBackend.qml"
    }

    Loader {
        id: media
        asynchronous: true
        source: "backends/MediaBackend.qml"
    }

    Loader {
        id: clipboard
        asynchronous: true
        source: "backends/ClipboardBackend.qml"
    }

    function tileAvailable(key) {
        switch (key) {
        case "wifi": return !!wifi.item?.networkAvailable
        case "bluetooth": return !!bluetoothBackend?.adapter
        case "power": return (power.item?.profiles.length ?? 0) > 0
        case "night": return !!nightLight?.available
        case "quiet": return !!notifications
        case "awake": return !!keepAwake?.available
        case "battery": return !!battery.item?.available
        case "media": return !!media.item?.available
        case "clipboard": return !!clipboard.item?.available
        default: return true
        }
    }

    property var returnFocus: null

    function closePage() {
        pageModule = ""
        returnFocus?.forceActiveFocus(Qt.BacktabFocusReason)
        returnFocus = null
    }

    function openPage(module, trigger) {
        if (!inlinePages[module])
            return
        if ((module === "kcm_bluetooth" && !bluetoothBackend)
            || (module === "kcm_networkmanagement" && !wifi.item)
            || (module === "kcm_powerdevilprofilesconfig" && !power.item)) {
            settings?.openSettings(module)
            return
        }
        pageError = ""
        returnFocus = trigger
        let properties = {}
        switch (module) {
        case "media":
            if (!media.item) return
            properties = { media: media.item }
            break
        case "battery":
            if (!battery.item) return
            properties = { battery: battery.item }
            break
        case "tiles":
            properties = { tiles: tileEditorRows }
            break
        case "kcm_kscreen":
            properties = { brightness: brightness }
            break
        case "kcm_bluetooth":
            properties = { backend: bluetoothBackend }
            break
        case "kcm_nightlight":
            properties = { nightLight: nightLight }
            break
        case "kcm_powerdevilprofilesconfig":
            properties = { power: power.item }
            break
        case "kcm_networkmanagement":
            properties = { backend: wifi.item }
            break
        }
        pageLoader.setSource(inlinePages[module], properties)
        pageModule = module
    }

    Loader {
        id: pageLoader
        objectName: "detailPage"
        anchors.fill: parent
        anchors.margins: Design.SlateDark.popupPadding
        active: root.pageModule !== ""
        asynchronous: true
        visible: status === Loader.Ready
        focus: visible
        onLoaded: if (item) item.forceActiveFocus()
        Keys.onEscapePressed: root.closePage()
        onStatusChanged: if (status === Loader.Error) {
            const module = root.pageModule
            root.closePage()
            if (module.startsWith("kcm_") && settings)
                settings.openSettings(module)
            else
                root.pageError = qsTr("This panel could not be loaded.")
        }
    }

    Connections {
        target: pageLoader.item
        function onCloseRequested() { root.closePage() }
        function onSettingsRequested() { settings?.openSettings(root.pageModule) }
    }

    readonly property var tileDefinitions: [
        { key: "wifi", title: qsTr("Wi-Fi"), module: "kcm_networkmanagement" },
        { key: "bluetooth", title: qsTr("Bluetooth"), icon: "bluetooth-symbolic", module: "kcm_bluetooth" },
        { key: "power", title: qsTr("Power Mode"), subtitle: qsTr("Power profiles"), icon: "power-profile-balanced-symbolic", module: "kcm_powerdevilprofilesconfig" },
        { key: "night", title: qsTr("Night Light"), subtitle: qsTr("Color temperature"), icon: "night-light-symbolic", module: "kcm_nightlight" },
        { key: "quiet", title: qsTr("Do Not Disturb"), icon: "notifications-disabled-symbolic", module: "history" },
        { key: "display", title: qsTr("Display"), subtitle: qsTr("Resolution and refresh rate"), icon: "video-display-symbolic", module: "kcm_kscreen" },
        { key: "awake", title: qsTr("Keep Awake"), icon: "keep-awake-symbolic" },
        { key: "battery", title: qsTr("Battery"), icon: "battery-symbolic", module: "battery" },
        { key: "media", title: qsTr("Media"), icon: "media-symbolic", module: "media" },
        { key: "clipboard", title: qsTr("Clipboard"), subtitle: qsTr("Open history"), icon: "clipboard-history-symbolic" }
    ]

    readonly property var visibleTiles: orderedTiles(tileDefinitions)
        .filter(tile => !tile.hidden && tileAvailable(tile.key))

    readonly property var tileEditorRows: orderedTiles(tileDefinitions.map(tile => ({ key: tile.key, title: tile.title })))

    Connections {
        target: root.pageModule === "tiles" ? pageLoader.item : null
        function onTilesEdited(updated) {
            const preferences = JSON.stringify(updated.map(tile => ({key: tile.key, hidden: tile.hidden === true})))
            root.tilePreferencesEdited(preferences)
            pageLoader.item.tiles = updated
        }
    }

    required property var audio
    readonly property var settings: settingsLoader.item
    readonly property var session: sessionLoader.item
    readonly property var screenshot: screenshotLoader.item
    readonly property var brightness: brightnessLoader.item

    Loader {
        id: settingsLoader
        source: "backends/SettingsBackend.qml"
    }

    Loader {
        id: sessionLoader
        source: "backends/SessionBackend.qml"
    }

    Loader {
        id: screenshotLoader
        asynchronous: true
        source: "backends/ScreenshotBackend.qml"
    }

    Connections {
        target: root.notifications
        function onSettingsRequested() { root.settings?.openSettings("kcm_notifications") }
    }

    Loader {
        id: brightnessLoader
        source: "backends/BrightnessBackend.qml"
    }

    ColumnLayout {
        id: content
        visible: pageLoader.status !== Loader.Ready
        anchors.fill: parent
        anchors.margins: Design.SlateDark.popupPadding
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Item { Layout.fillWidth: true }

            Repeater {
                id: headerActions
                model: [
                    { icon: "view-list", objectName: "editTilesButton", label: qsTr("Edit quick settings"), action: button => root.openPage("tiles", button) },
                    { icon: "camera-photo", kind: "screenshot", label: qsTr("Open Spectacle"), action: () => {
                        root.pageError = ""
                        screenshot.openScreenshot(() => root.dismissRequested(),
                            () => root.pageError = qsTr("Could not open Spectacle. Check that it is installed."))
                    } },
                    { icon: "preferences-system", kind: "settings", label: qsTr("System Settings"), action: () => settings?.openSettings("") },
                    { icon: "system-lock-screen", kind: "lock", label: qsTr("Lock screen"), action: () => session?.lock() },
                    { icon: "system-shutdown", kind: "session", label: qsTr("Session menu"), action: () => session?.powerMenu() }
                ]

                Controls.AbstractButton {
                    id: headerButton
                    required property var modelData
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    padding: 8
                    Controls.ToolTip.text: modelData.label
                    Controls.ToolTip.visible: hovered
                    objectName: modelData.objectName ?? ""
                    Accessible.name: modelData.label
                    visible: {
                        switch (modelData.kind) {
                        case "screenshot": return !!root.screenshot?.available
                        case "settings": return !!root.settings
                        case "lock": return !!root.session?.canLock
                        case "session": return !!root.session?.canOpenMenu
                        default: return true
                        }
                    }
                    enabled: modelData.kind !== "screenshot" || !root.screenshot?.busy
                    onClicked: modelData.action(headerButton)
                    background: Rectangle {
                        radius: 18
                        border.width: headerButton.visualFocus ? 1 : 0
                        border.color: Design.SlateDark.accent
                        color: headerButton.down ? Design.SlateDark.selection : headerButton.hovered ? Design.SlateDark.hover : Design.SlateDark.surface
                    }
                    contentItem: SymbolicIcon {
                        iconName: headerButton.modelData.icon + "-symbolic"


                        color: Design.SlateDark.text
                        implicitWidth: 18
                        implicitHeight: 18
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            PillSlider {
                Layout.fillWidth: true
                id: volumeControl
                objectName: "volumeControl"
                iconName: root.audio?.iconName ?? "audio-volume-muted-symbolic"
                value: root.audio?.volume ?? 0
                subtitle: root.audio?.deviceName ?? qsTr("Audio unavailable")
                muted: !!root.audio?.muted
                enabled: !!root.audio?.available
                editable: !!root.audio?.volumeWritable
                iconClickable: !!root.audio?.available
                onValueEdited: newValue => root.audio?.setVolume(newValue)
                onIconClicked: root.audio?.toggleMute()
            }

            Controls.AbstractButton {
                id: outputButton
                objectName: "audioOutputsButton"
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                padding: 9
                enabled: !!root.audio
                Accessible.name: qsTr("Audio outputs")
                Accessible.description: audioDevices.expanded ? qsTr("Collapse audio outputs") : qsTr("Expand audio outputs")
                Controls.ToolTip.text: Accessible.name
                Controls.ToolTip.visible: hovered
                onClicked: audioDevices.expanded = !audioDevices.expanded
                Keys.onDownPressed: {
                    audioDevices.expanded = true
                    Qt.callLater(audioDevices.focusOutput, 0)
                }
                Keys.onEscapePressed: event => {
                    event.accepted = audioDevices.expanded
                    if (event.accepted)
                        audioDevices.collapse()
                }
                background: Rectangle {
                    radius: 12
                    color: outputButton.down ? Design.SlateDark.selection : outputButton.hovered || audioDevices.expanded ? Design.SlateDark.hover : Design.SlateDark.surface
                    border.color: Design.SlateDark.accent
                    border.width: outputButton.visualFocus ? 1 : 0
                }
                contentItem: SymbolicIcon {
                    iconName: audioDevices.expanded ? "go-up-symbolic" : "go-down-symbolic"

                    color: Design.SlateDark.text
                }
            }
        }

        AudioDevices {
            id: audioDevices
            trigger: outputButton
            onMixerRequested: trigger => root.openPage("mixer", trigger)
            objectName: "audioDevices"
            Layout.fillWidth: true
            audio: root.audio
        }

        PillSlider {
            Layout.fillWidth: true
            objectName: "mainBrightness"
            visible: !!brightness?.available
            accessibleName: qsTr("Brightness")
            iconName: "display-brightness-symbolic"
            value: brightness?.value ?? 0
            minimumValue: brightness?.minimumPercent ?? 5
            enabled: !!brightness?.available
            subtitle: brightness?.label ?? ""
            onValueEdited: newValue => brightness?.setBrightness(newValue)
        }

        Controls.Label {
            Layout.fillWidth: true
            visible: root.pageError.length > 0
            text: root.pageError
            color: Design.SlateDark.warningText
            wrapMode: Text.WordWrap
        }

        GridLayout {
            columns: 2
            uniformCellWidths: true
            columnSpacing: 8
            rowSpacing: 8
            Layout.fillWidth: true
            visible: root.visibleTiles.length > 0

            Repeater {
                model: root.visibleTiles

                QuickToggle {
                    Layout.fillWidth: true
                    title: modelData.key === "wifi" && (!wifi.item?.hasWifi || wifi.item?.wiredConnected)
                        ? qsTr("Network") : modelData.title
                    subtitle: {
                        switch (modelData.key) {
                        case "wifi":
                            return wifi.item?.connectionStatus ?? qsTr("Unavailable")
                        case "bluetooth":
                            return !bluetoothBackend?.adapter ? qsTr("Unavailable")
                                : bluetoothBackend.busy ? qsTr("Updating…")
                                : bluetoothBackend.error ? qsTr("Check details")
                                : bluetoothBackend.connectedCount > 0
                                    ? qsTr("%n device(s) connected", "", bluetoothBackend.connectedCount)
                                    : bluetoothBackend.powered ? qsTr("On") : qsTr("Off")
                        case "power":
                            return power.item?.profileLabel(power.item.activeProfile) || qsTr("Unavailable")
                        case "quiet":
                            return notifications?.quietStatus ?? qsTr("Unavailable")
                        case "awake":
                            return keepAwake?.status ?? ""
                        case "battery":
                            return battery.item ? qsTr("%1 · %2").arg(battery.item.level).arg(battery.item.status) : ""
                        case "media":
                            return media.item?.title ?? ""
                        default:
                            return modelData.subtitle
                        }
                    }
                    iconName: modelData.key === "wifi"
                        ? wifi.item?.wiredConnected ? "network-wired-symbolic"
                            : wifi.item?.wifiEnabled ? "network-wireless-signal-good-symbolic" : "network-wireless-disabled-symbolic"
                        : modelData.icon

                    active: modelData.key === "wifi" ? !!(wifi.item?.wiredConnected || wifi.item?.wifiEnabled)
                        : modelData.key === "bluetooth" ? !!bluetoothBackend?.powered
                        : modelData.key === "awake" ? !!keepAwake?.active
                        : modelData.key === "media" ? !!media.item?.playing
                        : modelData.key === "quiet" && !!notifications?.quiet
                    hasDetails: !!modelData.module
                    canToggle: modelData.module === "kcm_networkmanagement" ? !!wifi.item && (wifi.item.wiredConnected || !wifi.item.hasWifi || wifi.item.canEnable)
                        : modelData.module === "kcm_bluetooth" ? !!bluetoothBackend?.canToggle
                        : modelData.key !== "quiet" || !!root.notifications
                    detailsAccessibleName: modelData.key === "quiet" ? qsTr("Notification history") : ""
                    onDetailsRequested: trigger => root.openPage(modelData.module, trigger)
                    primaryAccessibleName: modelData.key === "display" && root.settings
                        ? qsTr("Configure display resolution and refresh rate") : ""
                    onClicked: trigger => {
                        if (modelData.key === "quiet") {
                            notifications?.toggleQuiet()
                            return
                        }
                        if (modelData.module === "kcm_networkmanagement" && wifi.item?.hasWifi && !wifi.item.wiredConnected)
                            wifi.item.setWifi(!wifi.item.wifiEnabled)
                        else if (modelData.module === "kcm_bluetooth")
                            bluetoothBackend.setPowered(!bluetoothBackend.powered)
                        else if (modelData.key === "awake")
                            keepAwake?.toggle()
                        else if (modelData.key === "clipboard") {
                            root.pageError = ""
                            clipboard.item?.openHistory(() => root.dismissRequested(),
                                () => root.pageError = qsTr("Could not open clipboard history."))
                        } else if (modelData.key === "display" && root.settings) {
                            root.settings.openSettings("kcm_kscreen")
                            root.dismissRequested()
                        } else if (modelData.module)
                            root.openPage(modelData.module, trigger)
                    }
                }
            }
        }
    }
}
