import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import "../design" as Design

Controls.AbstractButton {
    id: root

    property string title
    property string description
    property string symbol
    property string actionLabel
    property bool selected: false
    property bool actionOnly: false
    signal actionRequested()

    focusPolicy: actionOnly ? Qt.NoFocus : Qt.StrongFocus

    implicitHeight: 54
    leftPadding: 12
    rightPadding: 12
    Accessible.name: title
    Accessible.description: [description, actionLabel].filter(Boolean).join(" · ")

    background: Rectangle {
        radius: 12
        color: !root.actionOnly && (root.hovered || root.down) ? Design.SlateDark.hover
            : root.selected ? Design.SlateDark.selection : Design.SlateDark.surface
        border.color: Design.SlateDark.accent
        border.width: root.visualFocus ? 1 : 0
    }

    contentItem: RowLayout {
        spacing: 10

        SymbolicIcon {
            visible: root.symbol.length > 0
            iconName: root.symbol
            color: Design.SlateDark.text
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.title
                elide: Text.ElideRight
                color: Design.SlateDark.text
                font.pixelSize: Design.SlateDark.bodySize
                font.weight: Font.DemiBold
            }
            Text {
                Layout.fillWidth: true
                visible: text.length > 0
                text: root.description
                elide: Text.ElideRight
                color: Design.SlateDark.secondaryText
                font.pixelSize: Design.SlateDark.captionSize
            }
        }

        Text {
            visible: !root.actionOnly && root.actionLabel.length > 0
            text: root.actionLabel
            color: Design.SlateDark.accent
            font.pixelSize: Design.SlateDark.captionSize
        }

        SlateButton {
            visible: root.actionOnly && root.actionLabel.length > 0
            text: root.actionLabel
            Accessible.name: qsTr("%1: %2").arg(root.actionLabel).arg(root.title)
            onClicked: root.actionRequested()
        }

        SymbolicIcon {
            visible: root.selected
            iconName: "selection-check-symbolic"
            color: Design.SlateDark.accent
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
        }
    }
}
