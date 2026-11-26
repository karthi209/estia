import QtQuick
import "../design" as Design
import QtQuick.Layouts
import QtQuick.Controls as Controls

Rectangle {
    id: root

    property string detailsAccessibleName
    property string primaryAccessibleName
    property string title
    property string subtitle
    property string iconName

    property bool active: false
    property bool hasDetails: false
    property bool canToggle: true
    signal clicked(Item trigger)
    signal detailsRequested(Item trigger)

    implicitHeight: 54
    implicitWidth: 150
    radius: height / 2
    color: active ? Design.SlateDark.accent : Design.SlateDark.surface
    Behavior on color { ColorAnimation { duration: 100 } }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 3
        spacing: 2

        Controls.AbstractButton {
            id: primary
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.fillHeight: true
            leftPadding: 10
            rightPadding: 5
            enabled: root.canToggle
            Accessible.name: root.primaryAccessibleName || root.title
            Controls.ToolTip.text: root.title + " · " + root.subtitle
            Controls.ToolTip.visible: hovered && root.subtitle.length > 0
                && (tileTitle.truncated || tileSubtitle.truncated)
            Accessible.description: root.subtitle
            onClicked: root.clicked(primary)

            contentItem: RowLayout {
                spacing: 7
                SymbolicIcon {
                    iconName: root.iconName

                    color: root.active ? Design.SlateDark.accentText : Design.SlateDark.text
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        id: tileTitle
                        text: root.title
                        color: root.active ? Design.SlateDark.accentText : Design.SlateDark.text
                        font.pixelSize: Design.SlateDark.bodySize
                        font.weight: Font.DemiBold
                    }
                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        id: tileSubtitle
                        text: root.subtitle
                        color: root.active ? Design.SlateDark.accentText : Design.SlateDark.secondaryText
                        font.pixelSize: Design.SlateDark.captionSize
                    }
                }
            }
            background: Rectangle {
                radius: height / 2
                color: primary.down ? Design.SlateDark.pressedOverlay : primary.hovered ? Design.SlateDark.hoverOverlay : "transparent"
                border.width: primary.visualFocus ? 1 : 0
                border.color: root.active ? Design.SlateDark.accentText : Design.SlateDark.accent
            }
        }

        Controls.AbstractButton {
            id: disclosure
            visible: root.hasDetails
            Layout.preferredWidth: 32
            Layout.minimumWidth: 32
            Layout.fillHeight: true
            padding: 7
            Accessible.name: root.detailsAccessibleName || qsTr("%1 details").arg(root.title)
            onClicked: root.detailsRequested(disclosure)
            contentItem: SymbolicIcon {
                iconName: "go-next-symbolic"

                color: root.active ? Design.SlateDark.accentText : Design.SlateDark.text
            }
            background: Rectangle {
                radius: height / 2
                color: disclosure.down ? Design.SlateDark.pressedOverlay : disclosure.hovered ? Design.SlateDark.disclosureHover : Design.SlateDark.disclosureShade
                border.width: disclosure.visualFocus ? 1 : 0
                border.color: root.active ? Design.SlateDark.accentText : Design.SlateDark.accent
            }
        }
    }
}
