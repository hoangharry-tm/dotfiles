import QtQuick
import qs.Common

// A glass sheet: translucent surface + hairline border. niri blurs what's
// behind it for layer surfaces (see niri/rules.kdl).
Rectangle {
    color: Theme.glass
    radius: Theme.radiusLg
    border.width: 1
    border.color: Theme.hairline

    Behavior on color {
        ColorAnimation {
            duration: Theme.animSlow
        }
    }
}
