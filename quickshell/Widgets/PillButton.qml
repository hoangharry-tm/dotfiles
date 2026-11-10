import QtQuick
import qs.Common

// A small text pill (inline actions in popovers and rows) at one height,
// `controlSm`. `danger` is the destructive style: a quiet `error` wash and
// `error` text (Stop, Quit). Hover/press wash and spring come from Clickable.
Clickable {
    id: root

    property alias text: label.text
    property bool danger: false

    implicitWidth: label.implicitWidth + Theme.padControl * 2
    implicitHeight: Theme.controlSm
    radius: Theme.radiusFull
    color: pressed ? Theme.pressed : hovered ? (danger ? Theme.errorWashHover : Theme.hover) : (danger ? Theme.errorWash : Theme.tile)

    Label {
        id: label

        anchors.centerIn: parent
        color: root.danger ? Theme.error : Theme.text
        font.pixelSize: Theme.textXs
    }
}
