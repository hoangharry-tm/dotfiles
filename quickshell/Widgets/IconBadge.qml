import QtQuick
import qs.Common

// A round icon well. On an "on" tile (bright glass) the well turns clear
// again and the glyph goes dark, so the tile reads as one lit object.
Rectangle {
    property string glyph: ""
    property bool on: false

    width: Theme.control
    height: Theme.control
    radius: Theme.radiusFull
    color: on ? "transparent" : Theme.glassFill

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim
        }
    }

    Icon {
        anchors.centerIn: parent
        glyph: parent.glyph
        color: parent.on ? Theme.onGlass : Theme.text
    }
}
