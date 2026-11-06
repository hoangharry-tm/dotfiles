import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

// "Which-key" for niri: every shortcut from binds.kdl, grouped, searchable.
// Centered glass sheet; Esc or a click outside (Scrim) closes it.
PanelWindow {
    id: root

    required property ShellScreen modelData
    readonly property bool shown: Panels.isOpen("keybinds", modelData.name)

    readonly property int cols: 4
    readonly property int rowH: Theme.controlSm
    readonly property int headH: Theme.controlSm
    readonly property int searchH: Theme.controlLg
    readonly property int footerH: Theme.control
    // Search + hairline + footer + the gaps between them + sheet padding.
    readonly property int chrome: searchH + Theme.hairlineWidth + footerH + Theme.gapSection * 3 + Theme.padSheet * 2

    readonly property var columns: split(Keybinds.filter(search.text), cols)
    // Sized for the unfiltered content so the sheet doesn't resize (and jump) while typing.
    readonly property int bodyFull: Math.max(...split(Keybinds.groups, cols).map(colHeight), 0)
    readonly property int bodyMax: modelData.height - Theme.space2xl * 2 - chrome

    // Heights are in px; used both to balance columns and to size the sheet.
    function colHeight(col) {
        return col.reduce((h, g) => h + headH + g.rows.length * rowH, 0) + Math.max(col.length - 1, 0) * Theme.gapSection;
    }

    // Fill columns in reading order up to an even share (keeps sections intact).
    function split(groups, n) {
        const total = colHeight(groups), out = [[]];
        let cur = 0;
        for (const g of groups) {
            const h = colHeight([g]);
            if (cur > 0 && cur + h / 2 > total / n && out.length < n) {
                out.push([]);
                cur = 0;
            }
            out[out.length - 1].push(g);
            cur += h;
        }
        return out;
    }

    screen: modelData
    // Mapped only while shown: niri draws blur and shadow for the whole
    // surface, so the sheet is never faded or scaled (DESIGN.md "Elevation").
    visible: shown
    implicitWidth: modelData.width - Theme.space2xl * 2
    implicitHeight: chrome + Math.min(bodyFull, bodyMax)
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.namespace: "qs-keybinds"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onShownChanged: if (shown) {
        search.text = "";
        search.forceActiveFocus();
    }

    Glass {
        id: sheet

        anchors.fill: parent
        radius: Theme.radiusXl // = qs-keybinds layer rule in niri/rules.kdl

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.padSheet
            spacing: Theme.gapSection

            // Search
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: root.searchH
                spacing: Theme.gapInline

                Icon {
                    glyph: "󰌌"
                    size: Theme.iconLg
                    color: search.text ? Theme.primary : Theme.textMuted
                }

                TextInput {
                    id: search

                    Layout.fillWidth: true
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: Theme.textXl
                    selectionColor: Theme.primary
                    selectedTextColor: Theme.primaryText
                    clip: true
                    Keys.onEscapePressed: Panels.close()

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        visible: search.text === ""
                        text: "Search shortcuts"
                        color: Theme.textMuted
                        font.pixelSize: Theme.textXl
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.hairlineWidth
                color: Theme.hairline
            }

            // Columns of groups; scrolls if the screen is too short.
            Flickable {
                id: flick

                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: body.height
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Row {
                    id: body

                    readonly property real colW: (flick.width - (root.cols - 1) * Theme.gapSection) / root.cols

                    spacing: Theme.gapSection
                    height: Math.max(...root.columns.map(root.colHeight), 0)

                    Repeater {
                        model: root.columns

                        Column {
                            required property var modelData

                            width: body.colW
                            spacing: Theme.gapSection

                            Repeater {
                                model: parent.modelData

                                KeybindGroup {
                                    required property var modelData

                                    width: body.colW
                                    group: modelData
                                    rowHeight: root.rowH
                                    headHeight: root.headH
                                }
                            }
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    visible: root.columns[0].length === 0
                    text: "No shortcuts match"
                    color: Theme.textMuted
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: root.footerH
                spacing: Theme.spaceLg

                KeyHint {
                    key: "esc"
                    text: "close"
                }
                Item {
                    Layout.fillWidth: true
                }
                Label {
                    text: "~/.config/niri/binds.kdl"
                    color: Theme.textMuted
                    font.pixelSize: Theme.textXs
                }
            }
        }
    }
}
