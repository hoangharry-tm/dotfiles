import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

// Spotlight-style launcher: apps (ranked by fuzzy match + frecency), inline
// calculator (+ units/currency via qalc), `>` run, `:` wallpapers,
// `<` clipboard history, `.` emoji, `/` files, `?` web search. Rendering only; logic is in Services/Launch.
PanelWindow {
    id: root

    required property ShellScreen modelData
    readonly property bool shown: Panels.isOpen("launcher", modelData.name)
    readonly property var parsed: Launch.parse(search.text)
    readonly property string mode: parsed.mode
    readonly property bool grid: mode === "wall" || mode === "emoji"
    readonly property bool clipMode: mode === "clip"
    readonly property var results: Launch.items(parsed)
    property int current: 0

    screen: modelData
    // Mapped only while shown: niri draws blur and shadow for the whole
    // surface, so fading or scaling the sheet inside it would leave a ghost halo.
    visible: shown
    anchors.top: true
    margins.top: Math.round(modelData.height * 0.2)
    implicitWidth: clipMode ? Theme.launcherWidthWide : Theme.launcherWidth // resizing is fine; the sheet itself is never scaled
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
    // Sources refresh on entering their mode, never at startup.
    onModeChanged: {
        if (!shown)
            return;
        if (mode === "wall")
            Wallpapers.refresh();
        else if (mode === "clip")
            Clipboard.refresh();
        else if (mode === "emoji")
            Emoji.load();
        else if (mode === "file")
            FileSearch.refreshRecent();
    }
    // Kick off async sources (fd, qalc) once per query change, never per frame.
    onParsedChanged: {
        Launch.update(parsed);
        Clipboard.confirmClear = false;
    }
    onResultsChanged: {
        current = 0;
        syncPreview();
    }
    onCurrentChanged: {
        Clipboard.confirmClear = false;
        syncPreview();
    }

    // Clipboard preview follows the selection; nothing is decoded in other modes.
    function syncPreview() {
        if (shown && clipMode)
            Clipboard.inspect(results[current]?.entry ?? null);
    }

    // alt (Shift+Enter) runs the item's secondary action when it has one.
    function activate(i, alt = false) {
        const r = results[i];
        if (!r)
            return;
        (alt && r.alt ? r.alt : r.run)();
        Panels.close();
    }

    // Delete the selected entry; keep the cursor where it was (results reset it).
    function remove() {
        const r = results[current];
        if (!r?.remove)
            return;
        const at = current;
        r.remove();
        Qt.callLater(() => current = Math.min(at, results.length - 1));
    }

    // Clipboard extras: pin/unpin, open link or path, two-step clear all.
    function pin() {
        results[current]?.pin?.();
    }

    function openLink() {
        if (results[current]?.entry && Clipboard.openIt(results[current].entry))
            Panels.close();
    }

    function clearAll() {
        if (!Clipboard.confirmClear) {
            Clipboard.confirmClear = true;
            return;
        }
        Clipboard.clearAll();
    }

    function navigate(dx, dy) {
        const n = results.length;
        if (n === 0)
            return;
        const step = grid ? dx + dy * wallGrid.columns : dx + dy;
        // Wrap in lists (Spotlight feel); clamp in the grid so rows don't jump.
        current = grid ? Math.max(0, Math.min(n - 1, current + step)) : (current + step + n) % n;
        (grid ? wallGrid : clipMode ? clipPane : list).positionViewAtIndex(current, ListView.Contain);
    }

    Glass {
        id: sheet

        width: parent.width
        implicitHeight: column.implicitHeight + Theme.spaceMd * 2 // sheet inset 12: 28 - 12 = 16 highlight
        radius: Theme.radiusXl // = qs-launcher layer rule in niri/rules.kdl

        ColumnLayout {
            id: column

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spaceMd
            spacing: Theme.gapStack

            SearchField {
                id: search

                // Seed before the first frame, so a prefixed open (e.g. ":"
                // wallpapers) never flashes the app list; opened() then
                // consumes it.
                Component.onCompleted: text = Launch.seed

                Layout.fillWidth: true
                Layout.preferredHeight: Theme.fieldHeight
                Layout.leftMargin: Theme.padControl
                Layout.rightMargin: Theme.padControl
                placeholder: Launch.modes[root.mode].placeholder
                glyph: Launch.modes[root.mode].glyph
                chip: root.mode === "apps" ? "" : root.clipMode ? Clipboard.chipLabel(root.parsed.query) : Launch.modes[root.mode].label
                clipKeys: root.clipMode
                gridNav: root.grid
                onNavigate: (dx, dy) => root.navigate(dx, dy)
                onAccepted: alt => root.activate(root.current, alt)
                onRemoveRequested: root.remove()
                onPinRequested: root.pin()
                onOpenRequested: root.openLink()
                onClearRequested: root.clearAll()
                onDismissed: Panels.close()
            }

            ResultList {
                id: list

                Layout.fillWidth: true
                visible: !root.grid && !root.clipMode && root.results.length > 0
                model: root.grid ? [] : root.results
                current: root.current
                open: root.shown
                onChosen: i => root.activate(i)
                onHovered: i => root.current = i
            }

            ClipboardPane {
                id: clipPane

                Layout.fillWidth: true
                visible: root.clipMode && root.results.length > 0
                model: root.clipMode ? root.results : []
                current: root.current
                onChosen: i => root.activate(i)
                onHovered: i => root.current = i
            }

            WallpaperGrid {
                id: wallGrid

                Layout.fillWidth: true
                visible: root.grid && root.results.length > 0
                model: root.grid ? root.results : []
                columns: root.mode === "emoji" ? 8 : 4
                maxRows: root.mode === "emoji" ? 4 : 3
                ratio: root.mode === "emoji" ? 1 : 0.68
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
                text: root.mode === "run" ? "Type a command" : root.mode === "clip" ? "Clipboard history is empty" : root.mode === "calc" ? "Type an expression, e.g. 12 * (3 + 4) or 5 km to mi" : root.mode === "file" ? (FileSearch.query ? "No files found" : "No recent files") : root.grid ? "No wallpapers in ~/Pictures/Wallpapers" : "No results"
            }

            // Footer: key hints, plus prefix modes while the field is empty.
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.padControl
                Layout.rightMargin: Theme.padControl
                Layout.preferredHeight: Theme.control
                spacing: Theme.spaceLg

                KeyHint {
                    key: "↵"
                    text: root.mode === "wall" ? "apply" : root.clipMode ? "paste" : root.mode === "calc" || root.mode === "emoji" || root.results[root.current]?.id === "calc" ? "copy" : "open"
                }
                KeyHint {
                    key: root.grid ? "←↑↓→" : "↑↓"
                    text: "navigate"
                }
                KeyHint {
                    key: "esc"
                    text: "close"
                }

                KeyHint {
                    visible: root.clipMode
                    key: "⇧↵"
                    text: "copy"
                }
                KeyHint {
                    visible: root.clipMode
                    key: "⌃P"
                    text: results[current]?.entry?.pinned ? "unpin" : "pin"
                }
                KeyHint {
                    visible: root.clipMode && (results[current]?.kind === "link" || results[current]?.kind === "path")
                    key: "⌃O"
                    text: "open"
                }
                KeyHint {
                    visible: root.clipMode
                    key: "⇧⌦"
                    text: "delete"
                }
                KeyHint {
                    visible: root.clipMode && !Clipboard.confirmClear
                    key: "⌃⇧⌦"
                    text: "clear all"
                }
                // Confirm step: the same chord again wipes cliphist (pins stay).
                KeyHint {
                    visible: root.clipMode && Clipboard.confirmClear
                    key: "⌃⇧⌦"
                    text: "again to clear ALL history"
                    color: Theme.error
                }
                KeyHint {
                    visible: root.mode === "file"
                    key: "⇧↵"
                    text: "reveal"
                }

                // Prefix hints: full labels when they fit, else bare keycaps
                // (measured by a hidden twin, so it never overflows or loops).
                Item {
                    id: prefixes

                    readonly property var all: [[">", "run"], ["=", "calc"], [":", "wallpapers"], ["<", "clipboard"], [".", "emoji"], ["/", "files"], ["?", "web"], ["+", "note"]]
                    readonly property bool compact: measure.implicitWidth > width

                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.control
                    visible: search.text === ""
                    clip: true

                    Row {
                        id: measure

                        visible: false
                        spacing: Theme.spaceLg

                        Repeater {
                            model: prefixes.all

                            KeyHint {
                                required property var modelData

                                key: modelData[0]
                                text: modelData[1]
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: prefixes.compact ? Theme.spaceMd : Theme.spaceLg

                        Repeater {
                            model: prefixes.all

                            KeyHint {
                                required property var modelData

                                key: modelData[0]
                                text: prefixes.compact ? "" : modelData[1]
                            }
                        }
                    }
                }
            }
        }
    }
}
