import QtQuick
import QtQuick.Layouts
import qs.Common

// One line in a card: [icon] label ........ value. Icon box is always
// reserved when `glyph` is set, so labels in a card start on the same x.
RowLayout {
    id: root

    property string glyph
    property string label
    property string value
    property color valueColor: Theme.text
    property bool mono: false

    Layout.fillWidth: true
    spacing: Theme.gapInline

    Icon {
        visible: root.glyph !== ""
        glyph: root.glyph
        color: Theme.textMuted
    }

    Label {
        text: root.label
        color: Theme.textMuted
    }

    Label {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        text: root.value
        color: root.valueColor
        font.family: root.mono ? Theme.mono : Theme.font
        font.pixelSize: root.mono ? Theme.textSm : Theme.textMd
    }
}
