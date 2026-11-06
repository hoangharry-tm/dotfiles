import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// Title (+ muted subtitle) on the left, the control(s) as children on the right.
Item {
    id: root

    property string title: ""
    property string subtitle: ""
    default property alias control: slot.data

    Layout.fillWidth: true
    implicitHeight: subtitle ? Theme.rowHeightTall : Theme.rowHeight

    Column {
        anchors.left: parent.left
        anchors.right: slot.left
        anchors.rightMargin: Theme.spaceMd
        anchors.verticalCenter: parent.verticalCenter

        Label {
            width: parent.width
            text: root.title
        }

        Label {
            width: parent.width
            visible: text !== ""
            text: root.subtitle
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }
    }

    Row {
        id: slot

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.gapInline
    }
}
