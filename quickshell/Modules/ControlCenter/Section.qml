import QtQuick
import QtQuick.Layouts
import qs.Common

// A grouped card inside the Control Center.
Rectangle {
    default property alias content: column.data
    property alias spacing: column.spacing

    implicitHeight: column.implicitHeight + 20
    radius: Theme.radiusMd
    color: Theme.tile
    border.width: 1
    border.color: Theme.hairline

    ColumnLayout {
        id: column

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 10
        spacing: 4
    }
}
