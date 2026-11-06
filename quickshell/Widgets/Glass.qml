import QtQuick
import qs.Common

// A glass sheet: translucent fill + hairline edge. niri blurs behind it and
// draws its shadow from the layer rule, so a sheet must fill its whole
// window, use the same radius as that rule, and never be transformed or
// faded (the compositor effects can't follow) — see DESIGN.md "Elevation".
Rectangle {
    color: Theme.glass
    radius: Theme.radiusLg
    border.width: Theme.hairlineWidth
    border.color: Theme.hairline

    Behavior on color {
        ColorAnimation {
            duration: Theme.animSlow
        }
    }
}
