import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

// Spotlight-style launcher: apps (ranked by fuzzy match + frecency), inline
// calculator, `>` run, `:` wallpapers. Rendering only; logic is in Services/Launch.
PanelWindow {
    id: root

    required property ShellScreen modelData
    readonly property bool shown: Panels.isOpen("launcher", modelData.name)
    readonly property var parsed: Launch.parse(search.text)
    readonly property string mode: parsed.mode
    readonly property bool grid: mode === "wall"
    readonly property var results: Launch.items(parsed)
    property int current: 0

    screen: modelData
    // Mapped only while shown: niri draws blur and shadow for the whole
    // surface, so fading or scaling the sheet inside it would leave a ghost halo.
    visible: shown
    anchors.top: true
    margins.top: Math.round(modelData.height * 0.2)
    implicitWidth: Theme.launcherWidth
    implicitHeight: sheet.implicitHeight
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.namespace: "qs-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Created on demand by a LazyLoader (shell.qml), so also run on creation.
    Component.onCompleted: if (shown) Qt.callLater(opened)
    // Deferred: shown can flip true mid-construction, before the search
    // field exists, and the seed (e.g. ":" for wallpapers) would be lost.
    onShownChanged: Qt.callLater(opened)

    // Both paths above can fire for one open (shown flips while the lazy
    // window initialises); run once, or the 2nd call wipes the consumed seed.
    property bool primed: false

    function opened() {
        if (!shown) {
            primed = false;
        } else if (!primed) {
            primed = true;
            search.text = Launch.seed;
            Launch.seed = "";
            current = 0;
            search.focusInput();
        }
    }
    onModeChanged: if (mode === "wall" && shown) Wallpapers.refresh()
    onResultsChanged: current = 0

    function activate(i) {
        const r = results[i];
        if (!r)
            return;
        r.run();
        Panels.close();
    }

    function navigate(dx, dy) {
        const n = results.length;
        if (n === 0)
            return;
        const step = grid ? dx + dy * wallGrid.columns : dx + dy;
        // Wrap in lists (Spotlight feel); clamp in the grid so rows don't jump.
        current = grid ? Math.max(0, Math.min(n - 1, current + step)) : (current + step + n) % n;
        (grid ? wallGrid : list).positionViewAtIndex(current, ListView.Contain);
    }

    Glass {
        id: sheet

        width: parent.width
        implicitHeight: column.implicitHeight + Theme.spaceMd * 2
        radius: Theme.radiusXl // = qs-launcher layer rule in niri/rules.kdl

        ColumnLayout {
            id: column

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spaceMd
            spacing: Theme.spaceXs

            SearchField {
                id: search

                // Seed before the first frame, so a prefixed open (e.g. ":"
                // wallpapers) never flashes the app list; opened() then
                // consumes it.
                Component.onCompleted: text = Launch.seed

                Layout.fillWidth: true
                Layout.preferredHeight: Theme.fieldHeight
                Layout.leftMargin: Theme.spaceMd
                Layout.rightMargin: Theme.spaceMd
                placeholder: Launch.modes[root.mode].placeholder
                glyph: Launch.modes[root.mode].glyph
                chip: root.mode === "apps" ? "" : Launch.modes[root.mode].label
                gridNav: root.grid
                onNavigate: (dx, dy) => root.navigate(dx, dy)
                onAccepted: root.activate(root.current)
                onDismissed: Panels.close()
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spaceMd
                Layout.rightMargin: Theme.spaceMd
                Layout.preferredHeight: Theme.hairlineWidth
                color: Theme.hairline
            }

            ResultList {
                id: list

                Layout.fillWidth: true
                visible: !root.grid && root.results.length > 0
                model: root.grid ? [] : root.results
                current: root.current
                open: root.shown
                onChosen: i => root.activate(i)
                onHovered: i => root.current = i
            }

            WallpaperGrid {
                id: wallGrid

                Layout.fillWidth: true
                visible: root.grid && root.results.length > 0
                model: root.grid ? root.results : []
                current: root.current
                onChosen: i => root.activate(i)
                onHovered: i => root.current = i
            }

            // Empty state
            Label {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.tileHeight
                visible: root.results.length === 0
                horizontalAlignment: Text.AlignHCenter
                color: Theme.textMuted
                text: root.mode === "run" ? "Type a command" : root.mode === "calc" ? "Type an expression, e.g. 12 * (3 + 4)" : root.grid ? "No wallpapers in ~/Pictures/Wallpapers" : "No results"
            }

            // Footer: key hints, plus prefix modes while the field is empty.
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spaceMd
                Layout.rightMargin: Theme.spaceMd
                Layout.preferredHeight: Theme.control
                spacing: Theme.spaceLg

                KeyHint {
                    key: "↵"
                    text: root.mode === "wall" ? "apply" : root.mode === "calc" || root.results[root.current]?.id === "calc" ? "copy" : "open"
                }
                KeyHint {
                    key: root.grid ? "←↑↓→" : "↑↓"
                    text: "navigate"
                }
                KeyHint {
                    key: "esc"
                    text: "close"
                }

                Item {
                    Layout.fillWidth: true
                }

                KeyHint {
                    visible: search.text === ""
                    key: ">"
                    text: "run"
                }
                KeyHint {
                    visible: search.text === ""
                    key: "="
                    text: "calc"
                }
                KeyHint {
                    visible: search.text === ""
                    key: ":"
                    text: "wallpapers"
                }
            }
        }
    }
}
