import QtQuick
import qs.Common

// Body text with theme defaults.
Text {
    color: Theme.text
    font.family: Theme.font
    font.pixelSize: Theme.textMd
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim
        }
    }
}
