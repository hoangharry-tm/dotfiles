import QtQuick
import qs.Common

// A round icon well (Control Center idiom). On: filled accent with a filled
// glyph in its ink; off: neutral well. The one colour mark on a flat tile.
Rectangle {
    property string glyph: ""
    property bool on: false

    width: Theme.control
    height: Theme.control
    radius: Theme.radiusFull
    color: on ? Theme.primary : Theme.hover

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }

    Icon {
        anchors.centerIn: parent
        glyph: parent.glyph
        filled: parent.on
        color: parent.on ? Theme.onAccent : Theme.text
    }
}
