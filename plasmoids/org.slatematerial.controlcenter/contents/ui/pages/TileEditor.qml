import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import "../components"

ColumnLayout {
    id: root
    required property var tiles
    signal closeRequested()
    signal settingsRequested()
    signal tilesEdited(var updated)

    RowLayout {
        SlateButton {
            text: qsTr("Back")
            onClicked: root.closeRequested()
        }
        Controls.Label {
            text: qsTr("Edit quick settings")
        }
    }

    Repeater {
        model: root.tiles.length

        RowLayout {
            id: row
            required property int index
            readonly property var tile: root.tiles[index]
            Layout.fillWidth: true

            Controls.CheckBox {
                Layout.fillWidth: true
                text: row.tile.title
                Binding on checked { value: !row.tile.hidden }
                onClicked: {
                    const updated = root.tiles.slice()
                    updated[row.index] = Object.assign({}, row.tile, {hidden: !row.tile.hidden})
                    root.tilesEdited(updated)
                }
            }
            SlateButton {
                text: "↑"
                Accessible.name: qsTr("Move %1 up").arg(row.tile.title)
                enabled: row.index > 0
                onClicked: move(-1)
            }
            SlateButton {
                text: "↓"
                Accessible.name: qsTr("Move %1 down").arg(row.tile.title)
                enabled: row.index + 1 < root.tiles.length
                onClicked: move(1)
            }

            function move(direction) {
                const updated = root.tiles.slice()
                const tile = updated.splice(index, 1)[0]
                updated.splice(index + direction, 0, tile)
                root.tilesEdited(updated)
            }
        }
    }
}
