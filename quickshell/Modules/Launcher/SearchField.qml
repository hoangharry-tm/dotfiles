import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// Search input with a mode glyph and a subtle mode chip. Owns key handling and
// reports intent; the launcher decides what navigation means per mode.
RowLayout {
    id: root

    property alias text: input.text
    property string placeholder: ""
    property string glyph: "󰍉"
    property string chip: ""      // shown when a prefix mode is active

    signal navigate(int dx, int dy)
    signal accepted
    signal dismissed

    function focusInput() {
        input.forceActiveFocus();
    }

    spacing: Theme.spaceMd

    Icon {
        glyph: root.glyph
        size: Theme.iconLg
        color: root.chip ? Theme.primary : Theme.textMuted
    }

    TextInput {
        id: input

        Layout.fillWidth: true
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: Theme.textXl
        selectionColor: Qt.alpha(Theme.primary, 0.4)
        clip: true

        Keys.onEscapePressed: root.dismissed()
        Keys.onReturnPressed: root.accepted()
        Keys.onEnterPressed: root.accepted()
        Keys.onTabPressed: root.navigate(1, 0)
        Keys.onBacktabPressed: root.navigate(-1, 0)
        Keys.onUpPressed: root.navigate(0, -1)
        Keys.onDownPressed: root.navigate(0, 1)
        // Left/Right move the caret unless navigation consumes them (grid).
        Keys.onLeftPressed: e => { e.accepted = root.gridNav; if (root.gridNav) root.navigate(-1, 0); }
        Keys.onRightPressed: e => { e.accepted = root.gridNav; if (root.gridNav) root.navigate(1, 0); }
        Keys.onPressed: e => {
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

    Rectangle {
        visible: root.chip !== ""
        implicitWidth: chipLabel.implicitWidth + Theme.spaceLg
        implicitHeight: Theme.controlSm
        radius: Theme.radiusFull
        color: Qt.alpha(Theme.primary, 0.16)

        Label {
            id: chipLabel

            anchors.centerIn: parent
            text: root.chip
            color: Theme.primary
            font.pixelSize: Theme.textXs
            font.weight: Font.DemiBold
        }
    }
}
