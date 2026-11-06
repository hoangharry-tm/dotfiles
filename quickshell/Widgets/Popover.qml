import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common

// Card that drops from a bar item: a layer-shell glass sheet (namespace
// qs-popover) so niri blurs and shadows it like every other sheet. One rule
// for placement: popoverGap below the bar's bottom edge, centered on `target`,
// clamped to the bar's outer margin so it never leaves the screen or touches
// the bar. Shown after a short hover delay (no flicker when the pointer just
// passes) and, if `interactive`, kept open while the pointer is over the card.
// Usage: Popover { target: chip; shown: chip.hovered; <content items> }
PanelWindow {
    id: root

    required property Item target
    property bool shown: false
    property bool interactive: false       // has controls: stays open under the pointer
    property int padding: Theme.padCard
    property int cardWidth: 0              // outer width; 0 = fit content
    default property alias content: column.data

    readonly property bool want: shown || (interactive && hover.hovered)
    property bool open: false
    property real centerX: 0               // target center in screen x, taken on open
    property ShellScreen host: null        // the target's screen, resolved on first hover (not yet parented at creation)

    function place() {
        const win = target.QsWindow.window;
        if (win)
            centerX = target.mapToItem(null, target.width / 2, 0).x + win.margins.left;
    }

    onOpenChanged: if (open)
        place()

    screen: host
    visible: open
    anchors.top: true
    anchors.left: true
    // Fixed distance from the screen top; ignore the bar's exclusive zone,
    // which would otherwise be added on top of the margin.
    exclusionMode: ExclusionMode.Ignore
    margins.top: Theme.popoverTop
    margins.left: host ? Math.round(Math.max(Theme.barMargin, Math.min(centerX - implicitWidth / 2, host.width - Theme.barMargin - implicitWidth))) : 0
    implicitWidth: cardWidth > 0 ? cardWidth : column.implicitWidth + padding * 2
    implicitHeight: column.implicitHeight + padding * 2
    color: "transparent"
    WlrLayershell.namespace: "qs-popover"
    WlrLayershell.layer: WlrLayer.Overlay
    // Passive cards let clicks through to what is underneath.
    mask: interactive ? null : passthrough

    Region {
        id: passthrough
    }

    // Debounce both edges: open after hover settles, close after the pointer
    // has really left (long enough to cross the gap into the card).
    Timer {
        interval: Theme.hoverOpen
        running: root.want && !root.open
        onTriggered: {
            root.host = root.target.QsWindow.window?.screen ?? null;
            root.open = root.host !== null;
        }
    }

    Timer {
        interval: Theme.hoverClose
        running: !root.want && root.open
        onTriggered: root.open = false
    }

    // Radius must equal the qs-popover layer rule in niri/rules.kdl.
    Glass {
        anchors.fill: parent
        radius: Theme.radiusLg
        visible: root.open // hidden content (Sparklines, art) goes idle

        HoverHandler {
            id: hover
        }

        ColumnLayout {
            id: column

            // Content (not the sheet) fades and rises in each time it opens.
            Enter {
                active: root.open
            }

            x: root.padding
            y: root.padding
            width: root.cardWidth > 0 ? root.cardWidth - root.padding * 2 : implicitWidth
            spacing: Theme.gapStack
        }
    }
}
