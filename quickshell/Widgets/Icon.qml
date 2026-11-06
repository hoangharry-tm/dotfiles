import QtQuick
import qs.Common

// A Nerd Font glyph (Material Design Icons range). Always a size x size box,
// so icons of different glyph widths align and space identically.
Text {
    id: icon

    property alias glyph: icon.text
    property int size: Theme.icon

    width: size
    height: size
    color: Theme.text
    font.family: Theme.mono
    font.pixelSize: size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim
        }
    }
}
