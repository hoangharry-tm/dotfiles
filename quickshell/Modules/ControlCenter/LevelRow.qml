import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Common
import qs.Widgets

// A compact level inside a dropdown list: a mark (app image or symbol), a
// name, a thin track and the value (tap it to mute). The large pill Slider is
// reserved for the sheet's two main levels; every level inside a list is this.
// Neutral fill only. Sits in a DetailList well, so the track is a `rest` lift.
RowLayout {
    id: root

    property string iconSource: ""      // app image; falls back to `glyph`
    property string glyph: "volume_up"
    property string label: ""
    property real value: 0
    property bool muted: false

    signal moved(real value)
    signal muteToggled

    implicitHeight: Theme.rowHeight
    spacing: Theme.gapInline

    // Left padding matches ListRow so icons align down the group.
    Layout.leftMargin: Theme.padControl
    Layout.rightMargin: Theme.padControl

    Item {
        Layout.preferredWidth: Theme.icon
        Layout.preferredHeight: Theme.icon

        IconImage {
            anchors.fill: parent
            visible: source !== ""
            source: root.iconSource
        }

        Icon {
            visible: root.iconSource === ""
            glyph: root.glyph
            filled: !root.muted
            color: root.muted ? Theme.textMuted : Theme.text
        }
    }

    Label {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        text: root.label
    }

    // Thin track: recessed well, neutral solid fill.
    Item {
        id: track

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        Layout.preferredHeight: Theme.control

        Surface {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: Theme.trackHeight
            radius: Theme.radiusFull
            variant: "trackInset" // lifts off the recessed well the list sits in (dark)

            Surface {
                width: Math.max(height, parent.width * drag.shown)
                height: parent.height
                radius: Theme.radiusFull
                variant: root.muted ? "on" : "solid"
            }
        }

        MouseArea {
            id: drag

            // Local value while dragging so the fill follows the pointer.
            property real local: 0
            readonly property real shown: pressed ? local : root.value

            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            preventStealing: true
            onPressed: m => set(m.x)
            onPositionChanged: m => {
                if (pressed)
                    set(m.x);
            }
            onWheel: w => w.accepted = false

            function set(x) {
                local = Math.max(0, Math.min(1, x / width));
                root.moved(local);
            }
        }
    }

    // Fixed width (the widest reading) so the track never shifts.
    TextMetrics {
        id: widest

        text: "Muted"
        font.pixelSize: Theme.textSm
        font.family: Theme.font
        // From the token, not font.pixelSize: reading the font group inside
        // its own binding loops.
        font.letterSpacing: Theme.tracking(Theme.textSm)
        font.variableAxes: {
            "opsz": Math.max(14, Theme.textSm)
        }
    }

    Button {
        id: level

        Layout.preferredWidth: widest.width + Theme.padControl * 2
        Layout.rightMargin: -level.inset // hang: the value stays on the content edge
        text: root.muted ? "Muted" : Math.round(root.value * 100) + "%"
        onClicked: root.muteToggled()
    }
}
