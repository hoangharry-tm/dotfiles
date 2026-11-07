pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Home-row mods (kanata, modules/keyboard.nix). `kbd-mods watch` holds kanata's
// localhost TCP connection and prints on/off on each layer change, or
// "unavailable" (retrying every 15 s) while the kanata unit is not running.
Singleton {
    id: root

    property string state: "unavailable"
    readonly property bool available: state !== "unavailable"
    readonly property bool on: state === "on"

    function toggle() {
        if (available)
            Quickshell.execDetached(["kbd-mods", "toggle"]);
    }

    Process {
        running: true
        command: ["kbd-mods", "watch"]
        stdout: SplitParser {
            onRead: line => root.state = line.trim()
        }
    }
}
