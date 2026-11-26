pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#272b30"
    readonly property color surface: "#353a41"
    readonly property color hover: "#41464e"
    readonly property color selection: "#435361"
    readonly property color accent: "#a2b4c4"
    readonly property color accentText: "#202830"
    readonly property color text: "#d5d9dd"
    readonly property color secondaryText: "#aeb5bd"
    readonly property color inactiveText: "#929aa3"
    readonly property color mutedTrack: "#626b74"
    readonly property color warningText: "#c4b28a"
    readonly property color disclosureShade: "#12000000"
    readonly property color hoverOverlay: "#18ffffff"
    readonly property color disclosureHover: "#24ffffff"
    readonly property color pressedOverlay: "#26000000"

    readonly property int titleSize: 16
    readonly property int bodySize: 13
    readonly property int labelSize: 12
    readonly property int captionSize: 11
    readonly property int annotationSize: 10

    readonly property int popupWidth: 360
    readonly property int popupRadius: 22
    readonly property int popupPadding: 16
}
