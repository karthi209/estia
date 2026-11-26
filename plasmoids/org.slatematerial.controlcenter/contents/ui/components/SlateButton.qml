import QtQuick
import "../design" as Design
import QtQuick.Controls as Controls

Controls.Button {
    id: root

    font.pixelSize: Design.SlateDark.bodySize
    leftPadding: 12
    rightPadding: 12
    topPadding: 8
    bottomPadding: 8
    implicitHeight: Math.max(36, implicitContentHeight + topPadding + bottomPadding)

    contentItem: Text {
        text: root.text
        font: root.font
        color: root.enabled ? Design.SlateDark.text : Design.SlateDark.inactiveText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: 12
        color: root.down ? Design.SlateDark.selection : root.hovered ? Design.SlateDark.hover : Design.SlateDark.surface
        border.width: root.activeFocus && root.visualFocus ? 1 : 0
        border.color: Design.SlateDark.accent
        Behavior on color { ColorAnimation { duration: 100 } }
    }
}
