import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Widgets

// The floating glass pill at the top of each screen.
PanelWindow {
    id: bar

    required property ShellScreen modelData

    screen: modelData
    anchors.top: true
    anchors.left: true
    anchors.right: true
    margins.top: Theme.barMargin
    margins.left: Theme.barMargin
    margins.right: Theme.barMargin
    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: "transparent"
    WlrLayershell.namespace: "qs-bar"
    WlrLayershell.layer: WlrLayer.Top

    // Radius must equal the qs-bar layer rule in niri/rules.kdl.
    Glass {
        anchors.fill: parent
        radius: Theme.radiusBar
    }

    // Layout model: the clock is truly centred and never overlapped. Each
    // side gets the room between its screen edge and the clock, minus barGap,
    // and collapses its items by priority (DESIGN.md, "Bar: responsive
    // priorities") until they fit. Everything derives from bar.width and
    // content metrics, so it adapts to scale/output changes with no feedback.
    function sideRoom(clockWidth) {
        return Math.max(0, bar.width / 2 - clockWidth / 2 - Theme.barGap - Theme.barPadX);
    }

    // Drop the weekday only if even fully-collapsed sides don't fit.
    readonly property int clockLevel: Math.max(workspaces.width + workspaces.edge, rightRow.minTotal) > sideRoom(clock.widths[0]) ? 1 : 0

    // Left: where you are
    Workspaces {
        id: workspaces

        anchors.left: parent.left
        anchors.leftMargin: Theme.barPadX + workspaces.edge
        anchors.verticalCenter: parent.verticalCenter
        output: bar.modelData.name
    }

    // Center: when
    Clock {
        id: clock

        anchors.centerIn: parent
        screenName: bar.modelData.name
        level: bar.clockLevel
    }

    // Right: what's going on
    ResponsiveRow {
        id: rightRow

        anchors.right: parent.right
        anchors.rightMargin: Theme.barPadX
        anchors.verticalCenter: parent.verticalCenter
        available: bar.sideRoom(clock.widths[bar.clockLevel])
        levels: 6 // 0 full, 1 titles shorten, 2 glyph-only media, 3 context chips go, 4 system+timer go, 5 battery % goes
        spacing: Theme.barGap

        NextEventChip {
            screenName: bar.modelData.name
            level: rightRow.level
        }

        // No weather chip: the Control Center and desktop show it (calm bar).

        MediaChip {
            level: rightRow.level
        }

        RecordChip {}

        FocusTimerChip {
            level: rightRow.level
        }

        ScreencastChip {}

        PrivacyDot {}

        InputMethodChip {
            level: rightRow.level
        }

        DriveChip {
            level: rightRow.level
        }

        SystemChip {
            level: rightRow.level
        }

        Tray {
            level: rightRow.level
        }

        StatusCluster {
            screenName: bar.modelData.name
            level: rightRow.level
        }
    }
}
