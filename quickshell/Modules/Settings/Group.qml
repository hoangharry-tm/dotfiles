import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// A titled card of rows (macOS grouped list). Rows go in as children.
ColumnLayout {
    id: root

    property string title: ""
    default property alias rows: column.data

    Layout.fillWidth: true
    spacing: Theme.spaceXs

    Label {
        visible: root.title !== ""
        Layout.leftMargin: Theme.spaceMd
        text: root.title
        color: Theme.textMuted
        font.pixelSize: Theme.textXs
        font.weight: Font.DemiBold
    }

    Surface {
        Layout.fillWidth: true
        implicitHeight: column.implicitHeight + Theme.spaceSm * 2
        radius: Theme.radiusMd // = sheet radius xl - padSheet

        ColumnLayout {
            id: column

            anchors.fill: parent
            anchors.margins: Theme.spaceSm
            anchors.leftMargin: Theme.spaceMd
            anchors.rightMargin: Theme.spaceMd
            spacing: 0
        }
    }
}
