import QtQuick
import qs.Common

// Body text with theme defaults: Inter at the size's own optical cut (opsz
// follows pixelSize, Inter's range is 14..32) and tracking (Theme.tracking).
Text {
    color: Theme.text
    font.family: Theme.font
    font.pixelSize: Theme.textMd
    onFontChanged: Theme.fitType(this)
    Component.onCompleted: Theme.fitType(this)
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }
}
