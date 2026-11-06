import QtQuick
import qs.Common

// The one glass recipe for every Control Center component: a neutral
// translucent veil over niri's blur, a 1px rim and a brighter specular line
// along the top edge (two hairlines, no gradient). `on` = bright frosted
// white (pair glyphs with Theme.onGlass); `recessed` = child surface one
// level below its parent (darker, inner shadow on top). Hover/press only
// step the alpha. Static: nothing animates at idle.
Rectangle {
    property bool on: false
    property bool recessed: false
    property bool hovered: false
    property bool pressed: false

    // Specular/shade line inset by the top corner radii so it follows the curve.
    readonly property real inset: Math.max(topLeftRadius, topRightRadius) * 0.6

    color: recessed ? Theme.recess : on ? (pressed ? Theme.glassOnPress : hovered ? Theme.glassOnHover : Theme.glassOn) : pressed ? Theme.glassFillPress : hovered ? Theme.glassFillHover : Theme.glassFill
    border.width: Theme.hairlineWidth
    border.color: recessed ? Theme.recessRim : Theme.glassRim

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }

    Rectangle {
        x: parent.inset
        y: Theme.hairlineWidth
        width: parent.width - parent.inset * 2
        height: Theme.hairlineWidth
        color: parent.recessed ? Theme.recessShade : Theme.glassRimTop
    }
}
