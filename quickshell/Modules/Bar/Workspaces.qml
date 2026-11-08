import QtQuick
import qs.Common
import qs.Services

// Workspaces as a page indicator (DESIGN.md, Bar, "Left, where"): dots with a
// constant edge-to-edge gap, the active one a pill (dot + gap + dot) so the
// rhythm holds when it moves. Meaning is by value, not hue.
Row {
    id: root

    required property string output

    readonly property int dot: Theme.spaceSm
    readonly property int gap: Theme.spaceSm

    // Bar adds this to barPadX so the first dot sits as far in as the last status icon.
    readonly property int edge: Theme.padControl

    spacing: gap

    Repeater {
        model: Niri.workspacesOn(root.output)

        Rectangle {
            id: ws

            required property var modelData

            readonly property bool current: modelData.is_active
            // A bool, not a list: stays put while niri re-emits windows on title changes.
            readonly property bool occupied: Niri.windowsOn(modelData.id).length > 0
            readonly property bool hovered: hit.containsMouse && !current

            width: current ? 2 * root.dot + root.gap : root.dot
            height: root.dot
            radius: Theme.radiusFull
            color: modelData.is_urgent ? Theme.error
                : current || (hovered && occupied) ? Theme.text
                : occupied || hovered ? Theme.textMuted
                : Theme.textFaint

            Behavior on width {
                enabled: Theme.motionAmbient

                NumberAnimation {
                    duration: Theme.anim
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curveDecelerate
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animFast
                }
            }

            // Half the gap each side, full bar height: targets tile with no dead zones.
            MouseArea {
                id: hit

                x: -root.gap / 2
                width: parent.width + root.gap
                height: Theme.barHeight
                anchors.verticalCenter: parent.verticalCenter
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Niri.focusWorkspace(ws.modelData.id)
            }
        }
    }
}
