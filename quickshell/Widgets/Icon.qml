import QtQuick
import qs.Common

// A Nerd Font glyph (Material Design Icons range).
Text {
    property alias glyph: icon.text
    property int size: Theme.icon

    id: icon

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
