import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Quick toggles: equal-width compact tiles. Five always (one row) plus
// Home-row mods when kanata is present (two rows of 3). No Capture tile: the
// screenshot keys already do that.
GridLayout {
    id: root

    required property var cc

    // Rows are always full: up to 5 tiles share one row, 6 make two rows of 3.
    readonly property int count: children.filter(c => c.visible !== false && c instanceof Tile).length
    columns: count > 5 ? 3 : Math.max(1, count)
    columnSpacing: Theme.gapStack
    rowSpacing: Theme.gapStack

    Tile {
        Layout.fillWidth: true
        Layout.preferredWidth: 1 // equal widths
        compact: true
        glyph: Notifications.dnd ? "do_not_disturb_on" : "notifications"
        title: "Focus"
        checked: Notifications.dnd
        onToggled: Notifications.dnd = !Notifications.dnd
        onHeld: focusMenu.open = !focusMenu.open
        z: focusMenu.open ? 1 : 0 // menu draws over the tiles below

        NotificationFocusMenu {
            id: focusMenu

            anchors.top: parent.bottom
            anchors.topMargin: Theme.spaceXs
            anchors.left: parent.left
        }

        Connections {
            target: root.cc

            function onShownChanged() {
                if (!root.cc.shown)
                    focusMenu.open = false;
            }
        }
    }

    Tile {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        compact: true
        glyph: "coffee"
        title: "Awake"
        checked: KeepAwake.enabled
        onToggled: KeepAwake.enabled = !KeepAwake.enabled
    }

    Tile {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        compact: true
        glyph: Glyphs.mic()
        title: Audio.micMuted ? "Mic off" : "Mic"
        checked: Audio.micMuted
        onToggled: Audio.toggleMicMute()
    }

    // Tap cycles off -> on -> auto (sunset to sunrise).
    Tile {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        compact: true
        glyph: "nightlight"
        title: NightLight.mode === "auto" ? "Night auto" : "Night"
        checked: NightLight.active
        onToggled: NightLight.cycle()
    }

    Tile {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        compact: true
        glyph: "screen_record"
        title: Recorder.recording ? Recorder.elapsedLabel : "Record"
        checked: Recorder.recording
        onToggled: {
            Panels.close();
            Recorder.toggle();
        }
    }

    Tile {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        compact: true
        visible: KbdMods.available
        glyph: "keyboard"
        title: "Home-row"
        checked: KbdMods.on
        onToggled: KbdMods.toggle()
    }
}
