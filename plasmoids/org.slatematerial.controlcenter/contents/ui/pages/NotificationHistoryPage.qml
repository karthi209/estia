import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"
import "../design" as Design

ColumnLayout {
    id: root
    spacing: 8
    signal closeRequested()
    signal settingsRequested()

    Loader {
        id: history
        asynchronous: true
        active: root.visible && (root.Window.window?.visible ?? true)
        source: "../backends/NotificationHistoryBackend.qml"
    }

    RowLayout {
        Layout.fillWidth: true
        SlateButton {
            text: qsTr("Back")
            onClicked: root.closeRequested()
        }
        Controls.Label {
            Layout.fillWidth: true
            text: qsTr("Notifications")
            font.bold: true
        }
    }

    Controls.Label {
        Layout.fillWidth: true
        visible: list.count === 0
        wrapMode: Text.WordWrap
        text: history.status === Loader.Error ? qsTr("Notification history unavailable")
            : history.status === Loader.Loading ? qsTr("Loading notifications…")
            : qsTr("No notifications in history")
    }

    ListView {
        id: list
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(280, contentHeight)
        visible: count > 0
        model: history.item
        spacing: 4
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        readonly property real gutter: Math.max(10, scrollbar.width) + 4

        Controls.ScrollBar.vertical: Controls.ScrollBar {
            id: scrollbar
            policy: Controls.ScrollBar.AsNeeded
        }

        delegate: Rectangle {
            required property string summary
            required property string applicationName
            required property var created
            width: Math.max(0, list.width - list.gutter)
            x: list.effectiveLayoutDirection === Qt.RightToLeft ? list.gutter : 0
            implicitHeight: labels.implicitHeight + 20
            height: implicitHeight
            radius: 12
            color: Design.SlateDark.surface

            ColumnLayout {
                id: labels
                anchors.fill: parent
                anchors.margins: 10
                spacing: 3

                Text {
                    Layout.fillWidth: true
                    text: summary || qsTr("Notification")
                    textFormat: Text.PlainText
                    color: Design.SlateDark.text
                    font.pixelSize: Design.SlateDark.bodySize
                    font.weight: Font.DemiBold
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: [
                        applicationName,
                        created && Number.isFinite(new Date(created).getTime())
                            ? new Date(created).toLocaleString(Qt.locale(), Locale.ShortFormat) : ""
                    ].filter(Boolean).join(" · ")
                    textFormat: Text.PlainText
                    color: Design.SlateDark.secondaryText
                    font.pixelSize: Design.SlateDark.captionSize
                    elide: Text.ElideRight
                }
            }
        }
    }
}
