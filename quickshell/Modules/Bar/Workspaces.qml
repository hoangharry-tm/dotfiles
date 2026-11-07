import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

// Workspaces as app-icon pills: each shows its windows' icons; the active one
// is wider (full-size icons on a primary pill), empty ones are dots.
Row {
    id: root

    required property string output

    // Responsive hooks (see ResponsiveRow). Collapse trades icons per pill:
    // 3 at level 0, 2 at level 1, 1 at level 2.
    property int level: 0
    readonly property bool wanted: true
    readonly property int maxIcons: 3

    function iconCap(l) {
        return Math.max(1, maxIcons - l);
    }

    // One pill's width: icons + spaceSm per side (empty: dot / wider when active).
    function pillWidth(n, active) {
        return n ? n * Theme.icon + (n - 1) * Theme.spaceXs + Theme.spaceSm * 2 : active ? Theme.spaceLg : Theme.spaceSm;
    }

    // Per-workspace unique app count + active flag, from data only.
    readonly property var plan: Niri.workspacesOn(output).map(w => ({
                n: new Set(Niri.windowsOn(w.id).map(x => x.app_id ?? "").filter(a => a)).size,
                active: w.is_active
            }))
    readonly property var widthAt: l => plan.reduce((sum, p) => sum + pillWidth(Math.min(p.n, iconCap(l)), p.active) + Theme.spaceXs * 2, 0)

    spacing: 0

    Repeater {
        model: Niri.workspacesOn(root.output)

        Clickable {
            id: ws

            required property var modelData

            readonly property bool active: modelData.is_active
            // A string (not an array) so the icon model only rebuilds when the
            // set of apps changes, not on every title change niri reports.
            readonly property string appKey: Niri.windowsOn(modelData.id).map(w => w.app_id ?? "").join("\n")
            readonly property var apps: appKey ? [...new Set(appKey.split("\n"))].slice(0, root.iconCap(root.level)) : []
            readonly property int iconSize: Theme.icon // fits controlSm pill with spaceXs vertical padding

            // Pill = icons + spaceSm padding per side; delegate adds spaceXs margin each side.
            readonly property int pillWidth: root.pillWidth(apps.length, active)
            width: pillWidth + Theme.spaceXs * 2
            height: Theme.control
            radius: Theme.radiusSm
            onClicked: Niri.focusWorkspace(modelData.id)

            Behavior on width {
                NumberAnimation {
                    duration: Theme.anim
                    easing.type: Theme.motionRich ? Easing.BezierSpline : Theme.easing
                    easing.bezierCurve: Theme.curveDecelerate
                }
            }

            // Pill / dot background
            Rectangle {
                anchors.centerIn: parent
                width: ws.pillWidth
                height: ws.apps.length ? Theme.controlSm : Theme.spaceSm
                radius: ws.apps.length ? Theme.radiusSm : Theme.radiusFull // bar 16 - inset 8
                // Outline-only: an active pill with icons is a hairline ring
                // (no fill); dots stay solid since they have no room for a ring.
                color: ws.apps.length ? "transparent" : ws.active ? Theme.primary : Theme.outline
                border.width: ws.apps.length && ws.active ? Theme.hairlineWidth : 0
                border.color: Theme.primaryRing
                opacity: ws.active || ws.apps.length ? 1 : 0.6

                // The pill grows with its slot instead of snapping (balanced and up).
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
                        duration: Theme.anim
                    }
                }
            }

            Row {
                id: icons

                anchors.centerIn: parent
                spacing: Theme.spaceXs
                opacity: ws.active ? 1 : 0.65

                Repeater {
                    model: ws.apps

                    Image {
                        id: img

                        required property string modelData

                        readonly property var entry: modelData ? DesktopEntries.heuristicLookup(modelData) : null

                        width: ws.iconSize
                        height: ws.iconSize
                        sourceSize: Qt.size(Theme.icon, Theme.icon)
                        source: Quickshell.iconPath(entry?.icon ?? modelData, "application-x-executable")
                        asynchronous: true
                        smooth: true
                    }
                }
            }
        }
    }
}
