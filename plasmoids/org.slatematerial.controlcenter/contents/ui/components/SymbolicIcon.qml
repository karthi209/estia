import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.Icon {
    property string iconName
    source: iconName.length ? Qt.resolvedUrl("../design/icons/" + iconName + ".svg") : ""
    isMask: true
}
