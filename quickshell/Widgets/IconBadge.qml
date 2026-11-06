import QtQuick
import qs.Common

// A round icon well; inverts onto the accent when its tile is on.
Rectangle {
    property string glyph: ""
    property bool on: false

    width: Theme.control
    height: Theme.control
    radius: Theme.radiusFull
    color: on ? Theme.primaryWash : Theme.tile

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim
        }
    }

    Icon {
        anchors.centerIn: parent
        glyph: parent.glyph
        color: parent.on ? Theme.primaryText : Theme.text
    }
}
