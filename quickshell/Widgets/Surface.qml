import QtQuick
import QtQuick.Shapes
import qs.Common

// The one material for every Control Center component: a diagonal two-stop
// tonal gradient (palette-derived, see Theme.tone*) with a static film-grain
// tile and a 1px rim. Variants:
//   rest     quiet lift of the sheet
//   on       richer container tone; its gradient axis drifts slowly while a
//            sheet is open (Ambient.phase); pair text with Theme.onTone*
//   accent   vivid fill for sliders/play; pair with Theme.onAccent
//   recessed darker well, one level below its parent (child lists, tracks)
// Hover/press add a translucent text-colour overlay step. The grain is a
// pre-baked 96px tile (assets/grain.png), so it costs nothing at idle.
Item {
    id: root

    property string variant: "rest"
    property bool hovered: false
    property bool pressed: false
    property real radius: 0
    property real topLeftRadius: radius
    property real topRightRadius: radius
    property real bottomLeftRadius: radius
    property real bottomRightRadius: radius
    // Override per use (e.g. battery warning); default comes from the variant.
    property color fillA: variant === "on" ? Theme.toneOnA : variant === "accent" ? Theme.toneAccentA : variant === "recessed" ? Theme.toneRecessA : Theme.toneRestA
    property color fillB: variant === "on" ? Theme.toneOnB : variant === "accent" ? Theme.toneAccentB : variant === "recessed" ? Theme.toneRecessB : Theme.toneRestB
    property color rim: variant === "on" ? Theme.toneOnRim : variant === "recessed" ? Theme.toneRecessRim : Theme.toneRim
    readonly property bool drifts: variant === "on" || variant === "accent"
    readonly property color wash: pressed ? Theme.tonePress : hovered ? Theme.toneHover : "transparent"
    property color stopA: Qt.tint(fillA, wash)
    property color stopB: Qt.tint(fillB, wash)

    Behavior on stopA {
        ColorAnimation {
            duration: Theme.animFast
        }
    }
    Behavior on stopB {
        ColorAnimation {
            duration: Theme.animFast
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: Theme.hairlineWidth
            strokeColor: root.rim
            // Gradient axis: top-left -> bottom-right; "on" slides it with the ambient phase.
            fillGradient: LinearGradient {
                x1: 0
                y1: 0
                x2: root.width * (root.drifts ? 1 - Ambient.phase * 0.5 : 1)
                y2: root.height * (root.drifts ? 1 + Ambient.phase : 1) + (root.variant === "recessed" ? 0 : root.width * 0.15)

                GradientStop {
                    position: 0
                    color: root.stopA
                }
                GradientStop {
                    position: 1
                    color: root.stopB
                }
            }

            PathRectangle {
                x: Theme.hairlineWidth / 2
                y: Theme.hairlineWidth / 2
                width: root.width - Theme.hairlineWidth
                height: root.height - Theme.hairlineWidth
                topLeftRadius: Math.max(0, root.topLeftRadius - Theme.hairlineWidth / 2)
                topRightRadius: Math.max(0, root.topRightRadius - Theme.hairlineWidth / 2)
                bottomLeftRadius: Math.max(0, root.bottomLeftRadius - Theme.hairlineWidth / 2)
                bottomRightRadius: Math.max(0, root.bottomRightRadius - Theme.hairlineWidth / 2)
            }
        }
    }

    // Film grain: the tile drawn only where the rounded outline is a plain
    // rectangle (a middle band plus top/bottom strips between the corner
    // arcs), so no mask or offscreen texture is needed. Strips are disjoint
    // (no double alpha) and the image keeps the surface's origin so tiling is
    // seamless. Static: costs nothing at idle.
    Repeater {
        model: [
            { x: 0, y: Math.max(root.topLeftRadius, root.topRightRadius), w: root.width, h: root.height - Math.max(root.topLeftRadius, root.topRightRadius) - Math.max(root.bottomLeftRadius, root.bottomRightRadius) },
            { x: root.topLeftRadius, y: 0, w: root.width - root.topLeftRadius - root.topRightRadius, h: Math.max(root.topLeftRadius, root.topRightRadius) },
            { x: root.bottomLeftRadius, y: root.height - Math.max(root.bottomLeftRadius, root.bottomRightRadius), w: root.width - root.bottomLeftRadius - root.bottomRightRadius, h: Math.max(root.bottomLeftRadius, root.bottomRightRadius) }
        ]

        Item {
            required property var modelData

            x: modelData.x
            y: modelData.y
            width: Math.max(0, modelData.w)
            height: Math.max(0, modelData.h)
            clip: true

            Image {
                x: -parent.x
                y: -parent.y
                width: root.width
                height: root.height
                source: Qt.resolvedUrl("../assets/grain.png")
                fillMode: Image.Tile
                opacity: Theme.grainOpacity
            }
        }
    }
}
