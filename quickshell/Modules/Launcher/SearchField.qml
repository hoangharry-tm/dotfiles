import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// Search input with a mode symbol (in the same iconApp box as a result's icon,
// so the two share column A) and a neutral mode chip. Owns key handling and
// reports intent; the launcher decides what navigation means per mode.
RowLayout {
    id: root

    property alias text: input.text
    property string placeholder: ""
    property string glyph: "search"
    property string chip: ""      // shown when a prefix mode is active

    signal navigate(int dx, int dy)
    signal accepted(bool alt) // alt = Shift+Enter (secondary action)
    signal dismissed
    signal removeRequested // Shift+Del: delete the selected entry (clipboard)
    signal pinRequested // Ctrl+P (clipboard keys only)
    signal openRequested // Ctrl+O (clipboard keys only)
    signal clearRequested // Ctrl+Shift+Del (clipboard keys only)
    signal lookRequested // Ctrl+Y, or Space on an empty file query (file keys only)
    property bool lookKeys: false
    property bool clipKeys: false // Ctrl+P pins instead of moving up

    function focusInput() {
        input.forceActiveFocus();
    }

    spacing: Theme.gapInline

    Item {
        Layout.preferredWidth: Theme.iconApp
        Layout.preferredHeight: Theme.iconApp

        Icon {
            anchors.centerIn: parent
            glyph: root.glyph
            size: Theme.iconXl
            color: Theme.textMuted
        }
    }

    Input {
        id: input

        Layout.fillWidth: true
        font.pixelSize: Theme.textXl

        Keys.onEscapePressed: root.dismissed()
        Keys.onReturnPressed: e => root.accepted(!!(e.modifiers & Qt.ShiftModifier))
        Keys.onEnterPressed: e => root.accepted(!!(e.modifiers & Qt.ShiftModifier))
        Keys.onTabPressed: root.navigate(1, 0)
        Keys.onBacktabPressed: root.navigate(-1, 0)
        Keys.onUpPressed: root.navigate(0, -1)
        Keys.onDownPressed: root.navigate(0, 1)
        // Left/Right move the caret unless navigation consumes them (grid).
        Keys.onLeftPressed: e => { e.accepted = root.gridNav; if (root.gridNav) root.navigate(-1, 0); }
        Keys.onRightPressed: e => { e.accepted = root.gridNav; if (root.gridNav) root.navigate(1, 0); }
        Keys.onPressed: e => {
            if (root.clipKeys && e.key === Qt.Key_Delete && (e.modifiers & Qt.ShiftModifier) && (e.modifiers & Qt.ControlModifier)) {
                root.clearRequested();
                e.accepted = true;
                return;
            }
            if (root.clipKeys && (e.modifiers & Qt.ControlModifier) && (e.key === Qt.Key_P || e.key === Qt.Key_O)) {
                e.key === Qt.Key_P ? root.pinRequested() : root.openRequested();
                e.accepted = true;
                return;
            }
            // Quick Look: Ctrl+Y, or bare Space while the query is empty (it would
            // only add a leading blank, so typing "my file" is never hijacked).
            if (root.lookKeys && ((e.key === Qt.Key_Y && (e.modifiers & Qt.ControlModifier)) || (e.key === Qt.Key_Space && !e.modifiers && input.text === "/"))) {
                root.lookRequested();
                e.accepted = true;
                return;
            }
            if (e.key === Qt.Key_Delete && (e.modifiers & Qt.ShiftModifier)) {
                root.removeRequested();
                e.accepted = true;
                return;
            }
            if (e.modifiers & Qt.ControlModifier) {
                const d = { [Qt.Key_N]: 1, [Qt.Key_J]: 1, [Qt.Key_P]: -1, [Qt.Key_K]: -1 }[e.key];
                if (d) {
                    root.navigate(0, d);
                    e.accepted = true;
                }
            }
        }

        Label {
            anchors.verticalCenter: parent.verticalCenter
            visible: input.text === ""
            text: root.placeholder
            color: Theme.textMuted
            font.pixelSize: Theme.textXl
        }
    }

    property bool gridNav: false

    Surface {
        visible: root.chip !== ""
        implicitWidth: chipLabel.implicitWidth + Theme.padControl * 2
        implicitHeight: Theme.controlSm
        radius: Theme.radiusFull
        variant: "on"

        Label {
            id: chipLabel

            anchors.centerIn: parent
            text: root.chip
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
            font.weight: Theme.weightEmphasis
        }
    }
}
