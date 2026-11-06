import QtQuick
import QtQuick.Layouts
import qs.Common

// A grouped card inside the Control Center.
Rectangle {
    default property alias content: column.data
    property alias spacing: column.spacing

    implicitHeight: column.implicitHeight + Theme.padCard * 2
    radius: Theme.radiusMd
    color: Theme.tile

    ColumnLayout {
        id: column

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Theme.padCard
        spacing: Theme.gapStack
    }
}
