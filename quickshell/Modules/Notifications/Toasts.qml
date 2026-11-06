import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

// Incoming notifications, top-right of the focused screen: at most 3 app
// stacks. Hover pauses the timeout; they also stay in the Control Center.
PanelWindow {
    id: root

    required property ShellScreen modelData

    screen: modelData
    visible: Notifications.toastKeys.length > 0 && Panels.focusedScreen() === modelData.name && !Panels.isOpen("control", modelData.name)
    anchors.top: true
    anchors.right: true
    margins.top: Theme.popoverTop
    margins.right: Theme.edge
    implicitWidth: Theme.panelWidth
    implicitHeight: stack.implicitHeight
    // Ignore the bar's exclusive zone, else margins.top (already measured
    // from the screen edge) is added below the bar a second time.
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.namespace: "qs-toasts"
    WlrLayershell.layer: WlrLayer.Overlay
    // Only takes focus when a reply field is clicked.
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Column {
        id: stack

        width: parent.width
        spacing: Theme.gapStack

        // Cards below glide up when one leaves.
        move: Transition {
            NumberAnimation {
                properties: "y"
                duration: Theme.anim
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.curveDecelerate
            }
        }

        Repeater {
            // Keys, so a new toast does not rebuild (and re-animate) the others.
            model: ScriptModel {
                values: Notifications.toastKeys
            }

            NotificationGroup {
                id: group

                required property string modelData

                width: stack.width
                groupKey: modelData
                toast: true

                // Expiry pauses while hovered, dragged or typed in; a critical
                // notification keeps the whole group up. Restarts on a new one.
                Timer {
                    readonly property int secs: Notifications.groupTimeout(group.items)

                    interval: secs * 1000
                    running: secs > 0 && !group.interacting
                    onTriggered: Notifications.hideAll(group.items)
                }

                // Slide in from the right
                NumberAnimation on x {
                    from: Theme.space2xl
                    to: 0
                    duration: Theme.anim
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curveDecelerate
                }
                NumberAnimation on opacity {
                    from: 0
                    to: 1
                    duration: Theme.anim
                    easing.type: Theme.easing
                }
            }
        }
    }
}
