import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.Common
import qs.Services
import qs.Widgets

// Incoming notifications, top-right of the focused screen. The column never
// outgrows the screen: it shows as many app stacks as fit (newest first, any
// critical one always), folds the rest into a "+M more apps" pill, and caps the
// one fanned stack to the room the others leave (it scrolls inside). Hover pauses
// the timeout; everything also stays in the Control Center. Toasts are not niri-blurred (no qs-toasts layer
// rule): each card draws its own opaque-ish material, so the transparent margins
// of this window show the desktop untouched.
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
    // A fanning stack animates cards inside the window. The window jumps to the
    // final height once when the transition starts and shrinks when it ends,
    // never per frame (resizing a layer surface per frame stutters).
    implicitHeight: Math.min(stack.implicitHeight + slack, avail)
    // Input only where there are cards; the spare height stays click-through.
    mask: Region {
        item: stack
    }
    // Ignore the bar's exclusive zone, else margins.top (already measured
    // from the screen edge) is added below the bar a second time.
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.namespace: "qs-toasts"
    WlrLayershell.layer: WlrLayer.Overlay
    // No keyboard by default: niri hands an on-demand overlay focus when it
    // maps, so every new toast stole the user's typing. A click on a reply
    // field sets `replying` (Exclusive: the click already happened, so
    // on-demand wouldn't focus); Escape, send or the toasts closing release it.
    WlrLayershell.keyboardFocus: Notifications.replying ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    onVisibleChanged: if (!visible)
        Notifications.replying = false

    // Room for the column: screen minus bar and margins.
    readonly property real avail: modelData.height - Theme.popoverTop - Theme.edge
    readonly property real pillH: Theme.controlSm + Theme.gapStack
    // Stacks that fit while leaving a fanned one room for Theme.fanCards' worth of two cards.
    readonly property int fit: Math.max(1, Math.min(Theme.toastGroups, Math.floor((avail - pillH - 2 * Theme.toastGroupEst) / (Theme.toastGroupEst + Theme.gapStack))))
    // Newest `fit` groups, plus every critical one (those never fold).
    readonly property var shownKeys: {
        const keys = Notifications.toastKeys;
        let room = fit;
        const crit = k => Notifications.itemsIn(Notifications.toastIndex, k).some(n => n.urgency === NotificationUrgency.Critical);
        const flags = keys.map(crit);
        room = Math.max(0, fit - flags.filter(f => f).length);
        return keys.filter((k, i) => flags[i] || room-- > 0);
    }
    readonly property int folded: Notifications.toastKeys.length - shownKeys.length
    // What the other stacks take collapsed; the fanned one gets the rest.
    readonly property real collapsedSum: {
        void groups.count;
        let s = 0;
        for (let i = 0; i < groups.count; i++)
            s += (groups.itemAt(i)?.collapsedH ?? 0) + Theme.gapStack;
        return s + (folded > 0 ? pillH : 0);
    }

    readonly property real slack: {
        void groups.count;
        let s = 0;
        for (let i = 0; i < groups.count; i++)
            s += groups.itemAt(i)?.slack ?? 0;
        return s;
    }

    Column {
        id: stack

        width: parent.width
        spacing: Theme.gapStack

        // A new stack slides in from the right and fades (balanced and up).
        add: Transition {
            enabled: Theme.motionAmbient

            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Theme.anim
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curveDecelerate
                }

                NumberAnimation {
                    property: "x"
                    from: Theme.spaceLg
                    duration: Theme.anim
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.curveDecelerate
                }
            }
        }

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
            id: groups

            // Keys, so a new toast does not rebuild (and re-animate) the others.
            model: ScriptModel {
                values: root.shownKeys
            }

            NotificationGroup {
                id: group

                required property string modelData

                width: stack.width
                groupKey: modelData
                toast: true
                maxFanH: Math.max(collapsedH, root.avail - (root.collapsedSum - collapsedH - Theme.gapStack))
                // One stack fans at a time: taking the hover closes the others at once.
                onHotChanged: if (hot)
                    for (let i = 0; i < groups.count; i++)
                        if (groups.itemAt(i) !== group)
                            groups.itemAt(i)?.release()

                // Expiry pauses while hovered, dragged or typed in; a critical
                // notification keeps the whole group up. Restarts on a new one.
                Timer {
                    readonly property int secs: Notifications.groupTimeout(group.items)

                    interval: secs * 1000
                    running: secs > 0 && !group.interacting
                    onTriggered: Notifications.hideAll(group.items)
                }
            }
        }

        // Folded stacks: one compact pill that opens the Control Center list.
        Item {
            width: stack.width
            height: root.folded > 0 ? Theme.controlSm : 0
            visible: root.folded > 0

            Rectangle {
                anchors.right: parent.right
                width: foldedLabel.implicitWidth + Theme.padControl * 2
                height: Theme.controlSm
                radius: Theme.radiusFull
                color: Theme.glassSolid
                border.width: Theme.hairlineWidth
                border.color: Theme.hairline

                Clickable {
                    anchors.fill: parent
                    radius: parent.radius
                    onClicked: Panels.toggle("control", root.modelData.name)
                }

                Label {
                    id: foldedLabel

                    anchors.centerIn: parent
                    text: "+" + root.folded + " more app" + (root.folded > 1 ? "s" : "")
                    color: Theme.textMuted
                    font.pixelSize: Theme.textXs
                    font.features: { "tnum": 1 }
                }
            }
        }
    }
}
