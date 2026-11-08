import QtQuick
import qs.Common

// One icon, always a size x size box so glyphs of different widths align.
// `glyph` is either
//   - a Material Symbols Rounded name ("wifi", "volume_up"; fonts.google.com/icons):
//     the UI's icon family, one stroke weight (Theme.iconWeight) matched to
//     Inter. `filled` fills the shape (state "on"); the fill grows in over
//     animFast, the shell's one signature micro-interaction.
//   - a Nerd Font codepoint (legacy; brand/app marks with no symbol).
// Names are plain lowercase words; Nerd glyphs are private-use characters, so
// the two never collide and every `glyph:` passthrough keeps working.
Text {
    id: icon

    property string glyph: ""
    property bool filled: false
    property int size: Theme.icon

    readonly property bool symbol: /^[a-z][a-z0-9_]*$/.test(glyph)
    // FILL axis 0..1, animated: an outline fills in when something turns on.
    property real fill: filled ? 1 : 0
    Behavior on fill {
        NumberAnimation {
            duration: Theme.animFast
            easing.type: Theme.easing
        }
    }

    text: glyph
    width: size
    height: size
    color: Theme.text
    font.family: symbol ? Theme.symbols : Theme.mono
    font.pixelSize: size
    font.variableAxes: symbol ? {
        "FILL": fill,
        "wght": Theme.iconWeight,
        "GRAD": Theme.iconGrade,
        "opsz": Math.max(20, Math.min(48, size))
    } : ({})
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: symbol ? Text.QtRendering : Text.NativeRendering

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }
}
