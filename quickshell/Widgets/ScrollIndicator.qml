import QtQuick
import qs.Common

// Thin neutral scroll indicator for a Flickable / ListView / GridView.
// Usage, as a child of the view or of anything else: `ScrollIndicator { flick: theView }`.
// It reparents itself onto `flick` (so it never scrolls with the content) and
// sits on its right edge. At rest it is invisible; it shows while the view
// moves (wheel, drag, keyboard) or is hovered, fades out `linger` ms after,
// and is hidden entirely when the content fits. Idle cost: none (no loops;
// the thumb only re-evaluates when the scroll position changes).
Item {
    id: root

    required property Flickable flick

    readonly property int linger: Theme.scrollLinger
    readonly property int thickness: Theme.spaceXs / 2
    readonly property int inset: Theme.spaceXs / 2
    readonly property int minThumb: Theme.spaceMd
    readonly property real range: flick.contentHeight
    readonly property bool scrollable: range > flick.height + 1
    readonly property real track: height - inset * 2
    readonly property bool shown: scrollable && (flick.moving || hover.hovered || linger_.running)

    parent: flick
    x: 0
    y: 0
    width: flick.width
    height: flick.height
    z: 1
    visible: thumb.opacity > 0
    enabled: false // never takes input; HoverHandler below is passive

    HoverHandler {
        id: hover
    }

    Timer {
        id: linger_

        interval: root.linger
    }

    Connections {
        target: root.flick
        enabled: root.scrollable

        function onContentYChanged() {
            linger_.restart();
        }
    }

    Rectangle {
        id: thumb

        readonly property real ratio: Math.min(1, root.flick.height / Math.max(1, root.range))
        readonly property real travel: root.track - height

        width: root.thickness
        height: Math.max(root.minThumb, root.track * ratio)
        x: root.width - width - root.inset
        y: root.inset + (root.range > root.flick.height ? Math.max(0, Math.min(1, (root.flick.contentY - root.flick.originY) / (root.range - root.flick.height))) * travel : 0)
        radius: Theme.radiusFull
        color: Theme.textFaint
        opacity: root.shown ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: root.shown ? Theme.animFast : Theme.animExit
                easing.type: Theme.easing
            }
        }
    }
}
