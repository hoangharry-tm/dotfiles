import QtQuick
import QtQuick.Layouts
import qs.Common

// The one button idiom (DESIGN.md "Interaction boxes"): a `control` high pill,
// `padControl` either side, label `textMd`. Hover/press are Clickable's wash.
//   quiet  no fill; the wash is the only box
//   tonal  `tile` fill under the wash
// `glyph` with an empty `text` is the icon-only form: a `control` circle.
// `busy` swaps the glyph for a spinner (a running scan). `tip` adds a tooltip.
// `inset` is how far the content sits inside the box, for callers that hang
// the box outward (negative margin) so the content stays on its column.
Clickable {
    id: root

    property string text: ""
    property string glyph: ""
    property string variant: "quiet"
    property bool busy: false
    property string tip: ""

    readonly property bool iconOnly: text === ""
    readonly property int inset: iconOnly ? (Theme.control - Theme.icon) / 2 : Theme.padControl
    readonly property color ink: hovered || pressed || variant === "tonal" ? Theme.text : Theme.textMuted

    implicitWidth: iconOnly ? Theme.control : row.implicitWidth + Theme.padControl * 2
    implicitHeight: Theme.control
    radius: Theme.radiusFull
    color: pressed ? Theme.pressed : hovered ? Theme.hover : variant === "tonal" ? Theme.tile : "transparent"

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: Theme.gapInline

        Icon {
            visible: root.glyph !== ""
            glyph: root.busy ? "progress_activity" : root.glyph
            color: root.ink

            RotationAnimation on rotation {
                running: root.busy && Theme.motionScale > 0
                from: 0
                to: 360
                duration: Theme.animSpin
                loops: Animation.Infinite
                onRunningChanged: if (!running)
                    parent.rotation = 0
            }
        }

        Label {
            visible: !root.iconOnly
            text: root.text
            color: root.ink
            font.features: {
                "tnum": 1
            }
        }
    }

    Loader {
        active: root.tip !== ""
        sourceComponent: Tooltip {
            target: root
            shown: root.hovered

            Label {
                text: root.tip
                font.pixelSize: Theme.textSm
            }
        }
    }
}
