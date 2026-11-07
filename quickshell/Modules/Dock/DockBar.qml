import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

// The dock sheet: bottom centre, one glass rectangle that fills its window
// (niri draws blur + shadow, see rules.kdl qs-dock). Hidden = this window is
// not loaded (LazyLoader in shell.qml), so it is never faded or scaled;
// only the icons inside rise in (Enter) and magnify on hover.
PanelWindow {
    id: root

    required property ShellScreen modelData

    readonly property int iconSize: Settings.dockIconSize
    readonly property int slot: iconSize + Theme.spaceSm     // icon + wash inset
    readonly property int dotBand: Theme.spaceSm              // room for the running dot
    readonly property int sepSpace: Theme.spaceMd             // pinned | running divider
    // Magnification stays inside the sheet's padding (+12% max): the glass
    // never resizes. "macos" spreads it as a cosine wave over neighbours
    // (reach by motion tier, 0 on low); "minimal" lifts only the hovered icon.
    readonly property bool mac: Settings.dockStyle !== "minimal"
    readonly property real magnify: mac ? 0.12 : 0.08
    readonly property int reach: mac ? Theme.motionLevel + 1 : 0   // neighbours either side that follow
    readonly property int stride: slot + Theme.spaceXs             // distance between slot starts
    readonly property bool bounce: mac && Theme.motionLevel >= 1   // launch/attention hops

    // drag-to-reorder (pinned only); DockItem reads these to slide neighbours
    property string dragKey: ""
    property int dragIndex: -1
    property int dragTarget: -1

    property var itemsByKey: ({})
    property var keys: []
    property int pinnedCount: 0
    property int hoverIndex: -1
    property bool shown: false

    // Items are rebuilt on any window/focus/pin change, but the Repeater
    // only resets when the key list changes (keeps hover + springs alive).
    function refresh() {
        const list = Dock.build(Niri.windows, Niri.mru, Settings.dockPinned);
        const map = {};
        for (const i of list)
            map[i.key] = i;
        itemsByKey = map;
        pinnedCount = list.filter(i => i.pinned).length;
        const k = list.map(i => i.key);
        if (k.join("|") !== keys.join("|"))
            keys = k;
    }

    screen: modelData
    anchors.bottom: true
    margins.bottom: Theme.edge
    implicitWidth: row.implicitWidth + Theme.spaceSm * 2
    implicitHeight: row.implicitHeight + Theme.spaceSm * 2
    exclusionMode: Settings.dockAutoHide ? ExclusionMode.Ignore : ExclusionMode.Auto
    color: "transparent"
    WlrLayershell.namespace: "qs-dock"
    WlrLayershell.layer: WlrLayer.Top

    Component.onCompleted: {
        refresh();
        shown = true;   // starts the icons'"'"' entrance
    }
    Component.onDestruction: {
        Dock.dockHover = false;
        Dock.menuKey = "";
    }

    Connections {
        target: Niri
        function onWindowsChanged() { Qt.callLater(root.refresh); }
        function onMruChanged() { Qt.callLater(root.refresh); }
        function onFocusedWindowIdChanged() { Qt.callLater(root.refresh); }
    }

    Connections {
        target: Settings
        function onDockPinnedChanged() { Qt.callLater(root.refresh); }
    }

    Glass {
        anchors.fill: parent
        radius: Theme.radiusLg   // = qs-dock layer rule in niri/rules.kdl

        HoverHandler {
            onHoveredChanged: Dock.dockHover = hovered
        }

        Row {
            id: row

            anchors.centerIn: parent
            spacing: Theme.spaceXs

            Repeater {
                model: root.keys

                DockItem {
                    required property string modelData

                    dock: root
                    key: modelData
                }
            }

            Enter {
                active: root.shown
            }
        }
    }
}
