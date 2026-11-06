import QtQuick
import qs.Common

// A row in a detail list (networks, devices, outputs): icon, text, trailing.
Clickable {
    id: root

    property string glyph: ""
    property string title: ""
    property string subtitle: ""
    property string trailingGlyph: ""
    property bool selected: false
    property bool busy: false

    implicitHeight: subtitle ? 46 : 38
    radius: Theme.radiusSm

    Icon {
        id: leading

        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: 22
        glyph: root.glyph
        color: root.selected ? Theme.primary : Theme.text
    }

    Column {
        anchors.left: leading.right
        anchors.leftMargin: 10
        anchors.right: trailing.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter

        Label {
            width: parent.width
            text: root.title
            font.weight: root.selected ? Font.DemiBold : Font.Normal
        }

        Label {
            width: parent.width
            text: root.subtitle
            visible: text !== ""
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }
    }

    Icon {
        id: trailing

        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        glyph: root.busy ? "󰔟" : root.trailingGlyph
        color: root.selected ? Theme.primary : Theme.textMuted

        RotationAnimation on rotation {
            running: root.busy
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
        }
    }
}
