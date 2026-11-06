import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

// Incoming notifications, top-right of the focused screen. Hover pauses the
// timeout; they also stay in the Control Center history.
PanelWindow {
    id: root

    required property ShellScreen modelData

    screen: modelData
    visible: Notifications.toasts.length > 0 && Panels.focusedScreen() === modelData.name && !Panels.isOpen("control", modelData.name)
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
            model: Notifications.toasts

            NotificationCard {
                id: card

                required property var modelData

                width: stack.width
                notification: modelData
                toast: true
                onClosed: Notifications.dismiss(modelData)

                Timer {
                    interval: Notifications.timeoutOf(card.modelData) * 1000
                    running: interval > 0 && !card.hovered
                    onTriggered: Notifications.hide(card.modelData)
                }

                // Slide in from the right
                x: 0
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
