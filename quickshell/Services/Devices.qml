pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// KDE Connect devices (iPhone/Mac/...) via the `continuity-devices` script
// (D-Bus reads). Refreshes only while a consumer holds `active` (the open
// Control Center): one read on open, then every few seconds; idle = nothing.
Singleton {
    id: root

    property bool active: false
    property var list: []           // [{ id, name, type, paired, reachable, requestedByPeer, battery, charging }]
    readonly property bool any: list.length > 0

    function icon(d) {
        return d.type === "desktop" || d.type === "laptop" ? "󰌢" : d.type === "tablet" ? "󰓶" : "󰏲";
    }

    function state(d) {
        const bat = d.battery !== null && d.battery !== undefined ? "  ·  " + d.battery + "%" + (d.charging ? " charging" : "") : "";
        if (!d.paired)
            return d.requestedByPeer ? "Wants to pair, tap to accept" : d.reachable ? "Tap to pair" : "Not paired";
        return d.reachable ? "Connected" + bat : "Offline";
    }

    function run(cmd, id) {
        Quickshell.execDetached(["continuity", cmd, id]);
    }

    // Floating terminal (the `popup` niri rule) running the yazi file picker.
    function sendFile(id) {
        Quickshell.execDetached(["alacritty", "--class", "popup", "-e", "continuity", "send-file", id]);
    }

    function refresh() {
        if (!proc.running)
            proc.running = true;
    }

    onActiveChanged: if (active) {
        Quickshell.execDetached(["continuity", "refresh"]);
        refresh();
    }

    Timer {
        interval: 5000
        running: root.active
        repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: proc

        command: ["continuity-devices"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.list = JSON.parse(text);
                } catch (e) {
                    root.list = [];
                }
            }
        }
    }
}
