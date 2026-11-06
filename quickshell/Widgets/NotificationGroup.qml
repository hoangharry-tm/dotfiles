import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects
import Quickshell.Widgets
import qs.Common
import qs.Services

// Notifications of one app as a stack of real cards. Collapsed: the newest on
// top, a few more peeking beneath (+N more past that). Hovering the stack (or
// "Show all" in the Control Center) fans them out into a list: each card
// animates y/scale/height from its tucked pose to its list slot, staggered.
// A toast group fans at most `Theme.fanCards` cards (and never past `maxFanH`);
// the rest scroll inside it. Non-toast groups get a header: app icon, name, show all, clear group.
Item {
    id: root

    required property string groupKey
    property bool toast: false
    // Toasts and the history read different indexes of the same service.
    readonly property var items: Notifications.itemsIn(toast ? Notifications.toastIndex : Notifications.historyIndex, groupKey)
    readonly property bool canFan: items.length > 1
    readonly property bool expandable: !toast && canFan
    readonly property bool open: expandable && !!Notifications.expanded[groupKey]
    // Toasts only: the tallest this group may fan, set by the toast column so
    // the whole column fits the screen (Infinity = uncapped, e.g. the Control Center).
    property real maxFanH: Infinity
    property bool hot: false           // pointer over the stack (held a grace period after leaving)
    readonly property bool fanned: canFan && (open || hot)
    property int busy: 0               // cards being hovered, dragged or typed in
    readonly property bool interacting: busy > 0 || hot
    readonly property string name: items.length > 0 ? (items[0].appName || groupKey) : groupKey
    readonly property int layers: Math.min(items.length - 1, Theme.stackLayers)
    readonly property int more: Math.max(0, items.length - 1 - Theme.stackLayers)

    // Stack heights. Reads rep.count so these refresh when cards come and go.
    readonly property real topH: {
        void rep.count;
        return rep.itemAt(0)?.implicitHeight ?? 0;
    }
    readonly property real fullH: Math.max(0, slotOf(rep.count) - Theme.gapStack)
    // Fanned viewport: the first `fanCards` cards, shrunk to the room left. Scrolls past it.
    readonly property real capH: toast ? Math.max(0, slotOf(Math.min(Theme.fanCards, rep.count)) - Theme.gapStack) : fullH
    readonly property real fanH: Math.min(fullH, capH, maxFanH)
    readonly property real maxScroll: Math.max(0, fullH - fanH)
    readonly property bool overflowing: (fanned || moving) && maxScroll > 1
    property real scrollY: 0
    readonly property real collapsedH: topH + layers * Theme.stackPeek + (more > 0 ? Theme.controlSm / 2 : 0)
    property real stackH: fanned ? fanH : collapsedH
    property bool ready: false         // no height animation while the group is being built
    readonly property bool moving: heightAnim.running
    // Cards beyond the peeking ones exist from fanning until the collapse ends.
    // Imperative, not a binding on `moving`: that would loop through the card count.
    property bool keepAll: false
    // Extra height a toast window must already have while this stack animates, so
    // the window never resizes per frame (see Modules/Notifications/Toasts.qml).
    readonly property real slack: fanned || moving ? Math.max(fanH, collapsedH, stackH) - stackH : 0

    implicitHeight: column.implicitHeight

    // Top y of card i in the list.
    function slotOf(i) {
        let y = 0;
        for (let j = 0; j < i; j++)
            y += (rep.itemAt(j)?.implicitHeight ?? 0) + Theme.gapStack;
        return y;
    }

    onFannedChanged: {
        if (fanned)
            keepAll = true;
        else
            scrollY = 0; // glides back with the collapse
    }
    onFanHChanged: scrollY = Math.min(scrollY, maxScroll)

    // The toast column calls this when another group takes the hover.
    function release() {
        grace.stop();
        hot = false;
    }

    Component.onCompleted: {
        keepAll = fanned;
        Qt.callLater(() => ready = true);
    }

    // Leaving the stack holds it open briefly so crossing a gap does not collapse it.
    Timer {
        id: grace

        interval: Theme.hoverClose
        onTriggered: root.hot = false
    }

    Behavior on scrollY {
        NumberAnimation {
            duration: Theme.animFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curveDecelerate
        }
    }

    Behavior on stackH {
        enabled: root.ready

        NumberAnimation {
            id: heightAnim

            duration: root.fanned ? Theme.animSlow : Theme.anim
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curveDecelerate
            onRunningChanged: if (!running && !root.fanned)
                root.keepAll = false
        }
    }

    ColumnLayout {
        id: column

        width: parent.width
        spacing: Theme.gapStack

        // Header: app icon, name, collapse, clear group.
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spaceMd
            visible: !root.toast
            spacing: Theme.gapInline

            Item {
                Layout.preferredWidth: Theme.iconLg
                Layout.preferredHeight: Theme.iconLg

                readonly property string source: root.items.length > 0 ? Notifications.appIconOf(root.items[0]) : ""

                IconImage {
                    anchors.fill: parent
                    source: parent.source
                    visible: parent.source !== ""
                }

                Icon {
                    anchors.centerIn: parent
                    glyph: "󰂚"
                    visible: parent.source === ""
                }
            }

            Label {
                Layout.fillWidth: true
                text: root.name
                color: Theme.textMuted
                font.pixelSize: Theme.textSm
                font.weight: Font.DemiBold
            }

            Clickable {
                visible: root.expandable
                Layout.preferredHeight: Theme.controlSm
                Layout.preferredWidth: less.implicitWidth + Theme.padControl * 2
                radius: Theme.radiusFull
                onClicked: Notifications.toggleGroup(root.groupKey)

                Label {
                    id: less

                    anchors.centerIn: parent
                    text: root.open ? "Show less" : "Show all"
                    color: Theme.textMuted
                    font.pixelSize: Theme.textXs
                }
            }

            Clickable {
                Layout.preferredWidth: Theme.controlSm
                Layout.preferredHeight: Theme.controlSm
                radius: Theme.radiusFull
                onClicked: Notifications.dismissAll(root.items)

                Icon {
                    anchors.centerIn: parent
                    glyph: "󰅖"
                    size: Theme.iconSm
                }
            }
        }

        // The stack: absolutely positioned cards inside a box of animated height.
        Item {
            id: area

            Layout.fillWidth: true
            Layout.preferredHeight: root.stackH
            clip: root.overflowing
            // Fade the clipped edges so "more below" reads; layered only while it scrolls.
            layer.enabled: root.overflowing
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: fadeMask
            }

            Rectangle {
                id: fadeMask

                anchors.fill: parent
                visible: false
                layer.enabled: true
                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: Qt.rgba(0, 0, 0, Math.min(1, 1 - root.scrollY / Theme.spaceXl))
                    }
                    GradientStop {
                        position: Theme.spaceXl / Math.max(area.height, 1)
                        color: "black"
                    }
                    GradientStop {
                        position: 1 - Theme.spaceXl / Math.max(area.height, 1)
                        color: "black"
                    }
                    GradientStop {
                        position: 1
                        color: Qt.rgba(0, 0, 0, Math.min(1, (root.maxScroll - root.scrollY) / Theme.spaceXl))
                    }
                }
            }

            // Wheel scrolls the fanned list (half a card a notch); it is inside the
            // hover area, so the group stays open and expiry stays paused.
            WheelHandler {
                enabled: root.maxScroll > 0 && root.fanned
                onWheel: ev => root.scrollY = Math.max(0, Math.min(root.maxScroll, root.scrollY - ev.angleDelta.y / 240 * root.topH))
            }

            HoverHandler {
                enabled: root.canFan
                onHoveredChanged: {
                    if (hovered) {
                        grace.stop();
                        root.hot = true;
                    } else if (root.hot) {
                        grace.restart();
                    }
                }
            }

            Item {
                id: inner

                width: parent.width
                height: parent.height
                y: -root.scrollY

                Repeater {
                    id: rep

                    model: ScriptModel {
                        values: root.keepAll ? root.items : root.items.slice(0, Theme.stackLayers + 1)
                    }

                    NotificationCard {
                        id: card

                        required property var modelData
                        required property int index

                        // depth eases when a card moves up or down the stack; fan is
                        // 0 tucked .. 1 in the list. `tuck` is how far behind the front it sits.
                        property real depth: index
                        property real fan: 0
                        property real slotY: root.slotOf(index)
                        readonly property real tuck: depth * (1 - fan)

                        width: area.width
                        height: root.topH * (1 - fan) + implicitHeight * fan
                        y: Math.min(depth, Theme.stackLayers) * Theme.stackPeek * (1 - fan) + slotY * fan
                        scale: 1 - Theme.stackShrink * Math.min(tuck, Theme.stackLayers)
                        transformOrigin: Item.Bottom
                        z: root.items.length - index
                        shade: Math.max(0, 1 - Theme.stackFade * tuck) * Math.min(1, Math.max(0, Theme.stackLayers + 1 - tuck))
                        visible: shade > 0.01
                        concealed: tuck > 0.5
                        notification: modelData
                        toast: root.toast
                        showApp: root.toast
                        expandBody: root.open
                        animateIn: root.toast && !root.keepAll
                        onClosed: Notifications.dismiss(modelData)
                        onInteractingChanged: root.busy += interacting ? 1 : -1
                        Component.onDestruction: if (interacting)
                            root.busy--
                        Component.onCompleted: fan = root.fanned ? 1 : 0

                        Behavior on depth {
                            NumberAnimation {
                                duration: Theme.anim
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Theme.curveDecelerate
                            }
                        }

                        // Cards glide to a new slot when a neighbour leaves or grows.
                        Behavior on slotY {
                            enabled: root.ready

                            NumberAnimation {
                                duration: Theme.anim
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Theme.curveDecelerate
                            }
                        }

                        // Fan out staggered (the delay is taken from the duration so
                        // every card lands with the stack's height); collapse together.
                        Behavior on fan {
                            SequentialAnimation {
                                PauseAnimation {
                                    duration: root.fanned ? Math.min(card.index, Theme.staggerMax) * Theme.stagger : 0
                                }

                                NumberAnimation {
                                    duration: root.fanned ? Math.max(0, Theme.animSlow - Math.min(card.index, Theme.staggerMax) * Theme.stagger) : Theme.anim
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Theme.curveDecelerate
                                }
                            }
                        }

                        Connections {
                            function onFannedChanged() {
                                card.fan = root.fanned ? 1 : 0;
                            }

                            target: root
                        }
                    }
                }

            }

            // "+N more" on the last peeking card.
            Rectangle {
                id: pill

                visible: root.more > 0 && opacity > 0
                opacity: root.fanned ? 0 : 1
                z: root.items.length + 1
                anchors.right: parent.right
                anchors.rightMargin: Theme.spaceMd
                y: root.topH + root.layers * Theme.stackPeek - height / 2
                width: moreLabel.implicitWidth + Theme.padControl * 2
                height: Theme.controlSm
                radius: Theme.radiusFull
                color: Theme.glassSolid
                border.width: Theme.hairlineWidth
                border.color: Theme.hairline

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animFast
                    }
                }

                Label {
                    id: moreLabel

                    anchors.centerIn: parent
                    text: "+" + root.more + " more"
                    color: Theme.textMuted
                    font.pixelSize: Theme.textXs
                }
            }
        }
    }
}
