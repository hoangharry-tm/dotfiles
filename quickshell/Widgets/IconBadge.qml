import QtQuick
import qs.Common

// A round icon well. On an "on" tile the well fills with the vivid accent
// and the glyph takes its ink: the one bright mark on a tonal tile.
Rectangle {
    property string glyph: ""
    property bool on: false

    width: Theme.control
    height: Theme.control
    radius: Theme.radiusFull
    color: on ? Theme.primary : Theme.toneHover

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim
        }
    }

    Icon {
        anchors.centerIn: parent
        glyph: parent.glyph
        color: parent.on ? Theme.onAccent : Theme.text
    }
}
