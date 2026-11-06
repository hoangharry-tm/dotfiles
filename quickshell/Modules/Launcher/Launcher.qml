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
    visible: shown || sheet.opacity > 0.01 // keep mapped while fading out
    anchors.top: true
    margins.top: Math.round(modelData.height * 0.2)
    implicitWidth: 640
    implicitHeight: sheet.implicitHeight
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.namespace: "qs-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onShownChanged: {
        if (shown) {
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
        implicitHeight: column.implicitHeight + 16
        radius: Theme.radiusXl
        opacity: root.shown ? 1 : 0
        scale: root.shown ? 1 : 0.97
        transformOrigin: Item.Top

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animFast
                easing.type: Theme.easing
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Theme.anim
                easing.type: Theme.easing
            }
        }

        ColumnLayout {
            id: column

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            spacing: 6

            SearchField {
                id: search

                Layout.fillWidth: true
                Layout.preferredHeight: 48
                Layout.leftMargin: Theme.pad
                Layout.rightMargin: Theme.pad
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
                Layout.preferredHeight: 1
                color: Theme.hairline
            }

            ResultList {
                id: list

                Layout.fillWidth: true
                visible: !root.grid && root.results.length > 0
                model: root.grid ? [] : root.results
                current: root.current
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
                Layout.preferredHeight: 64
                visible: root.results.length === 0
                horizontalAlignment: Text.AlignHCenter
                color: Theme.textMuted
                text: root.mode === "run" ? "Type a command" : root.mode === "calc" ? "Type an expression, e.g. 12 * (3 + 4)" : root.grid ? "No wallpapers in ~/Pictures/Wallpapers" : "No results"
            }

            // Footer: key hints, plus prefix modes while the field is empty.
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.pad
                Layout.rightMargin: Theme.pad
                Layout.bottomMargin: 4
                spacing: 14

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
