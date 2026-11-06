pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// (Named Ime: "InputMethod" collides with a Qt global.)
// fcitx5 state via `fcitx5-remote -n` (current engine name; fails when the
// daemon is down). fcitx5 emits no change signal, and its state is per
// focused window, so re-read on window focus and on a slow tick (catches the
// niri hotkey and daemon start/stop). Each read is one short process.
Singleton {
    id: root

    property bool running: false
    property string engine: ""
    readonly property bool vietnamese: engine !== "" && engine !== "keyboard-us"
    readonly property string label: vietnamese ? "VI" : "EN"

    function refresh() {
        if (!probe.running)
            probe.running = true;
    }

    function toggle() {
        toggler.running = true;
    }

    Process {
        id: probe

        command: ["fcitx5-remote", "-n"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.engine = text.trim();
                root.running = root.engine !== "";
            }
        }
        onExited: code => {
            if (code !== 0) {
                root.running = false;
                root.engine = "";
            }
        }
    }

    Process {
        id: toggler

        command: ["fcitx5-remote", "-t"]
        onExited: root.refresh()
    }

    Connections {
        target: Niri

        function onFocusedWindowIdChanged() {
            // fcitx5 applies the new window's state a beat after focus moves.
            settle.restart();
        }
    }

    Timer {
        id: settle

        interval: 150
        onTriggered: root.refresh()
    }

    Timer {
        interval: 2500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
