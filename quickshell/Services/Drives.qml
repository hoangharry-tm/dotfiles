pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Mounted removable drives. `removable watch` prints one JSON line now and one
// per udisks event (event-driven, no polling); empty list = chip hidden.
Singleton {
    id: root

    property var drives: []             // [{path, label, size, mount, disk}]
    readonly property bool any: drives.length > 0

    function eject(d) {
        ejector.command = ["removable", "eject", d.mount];
        ejector.running = true;
    }

    Process {
        running: true
        command: ["removable", "watch"]
        stdout: SplitParser {
            onRead: line => {
                try {
                    root.drives = JSON.parse(line);
                } catch (e) {}
            }
        }
    }

    Process {
        id: ejector
    }
}
