import QtQuick
import qs.Common

// Editable text with the same Inter treatment as Label (family, dynamic
// tracking, optical size). Monospace overrides skip tracking.
TextInput {
    color: Theme.text
    selectionColor: Theme.selection
    font.family: Theme.font
    font.pixelSize: Theme.textMd
    onFontChanged: Theme.fitType(this)
    Component.onCompleted: Theme.fitType(this)
    clip: true
    renderType: Text.NativeRendering
}
