import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

// Quick toggles: equal-width compact tiles (3 columns = two full rows).
GridLayout {
    id: root

    required property var cc

    columns: 3
    columnSpacing: Theme.gapStack
    rowSpacing: Theme.gapStack

    Tile {
        Layout.fillWidth: true
        Layout.preferredWidth: 1 // equal widths
        compact: true
        glyph: Notifications.dnd ? "󰂛" : "󰂚"
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
        glyph: KeepAwake.enabled ? "󰅶" : "󰾪"
        title: "Awake"
        checked: KeepAwake.enabled
        onToggled: KeepAwake.enabled = !KeepAwake.enabled
    }

    Tile {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        compact: true
        glyph: Audio.micIcon
        title: Audio.micMuted ? "Mic off" : "Mic"
        checked: Audio.micMuted
        onToggled: Audio.toggleMicMute()
    }

    // Tap cycles off -> on -> auto (sunset to sunrise).
    Tile {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        compact: true
        glyph: NightLight.active ? "󰖔" : "󰖙"
        title: NightLight.mode === "auto" ? "Night auto" : "Night"
        checked: NightLight.active
        onToggled: NightLight.cycle()
    }

    Tile {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        compact: true
        glyph: Recorder.recording ? "󰻃" : "󰑊"
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
        glyph: "󰹑"
        title: "Capture"
        onToggled: {
            Panels.close();
            Quickshell.execDetached(["sh", "-c", "sleep 0.3; niri msg action screenshot"]);
        }
    }
}
