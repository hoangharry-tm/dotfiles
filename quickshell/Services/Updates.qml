pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Flake update status written by the `updates` script (modules/updates.nix).
// File-watched, no polling; "Check now" starts the low-priority user unit.
Singleton {
    id: root

    readonly property string dir: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/updates"
    property bool known: false          // status.json exists
    property bool ok: true
    property string message: ""
    property real checkedAt: 0
    property int count: 0
    property var summary: []
    property var inputs: []
    property bool checking: false
    readonly property int nixpkgsDays: {
        const n = inputs.find(i => i.name === "nixpkgs");
        return n ? n.days : -1;
    }

    function check() {
        if (!checking) {
            checking = true;
            starter.running = true;
        }
    }

    FileView {
        path: root.dir + "/status.json"
        printErrors: false // absent until the first check
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: root.known = false
        onLoaded: {
            try {
                const s = JSON.parse(text());
                root.ok = s.ok;
                root.message = s.message || "";
                root.checkedAt = s.checkedAt;
                root.count = s.changedCount;
                root.summary = s.summary || [];
                root.inputs = s.inputs || [];
                root.known = true;
                root.checking = false;
            } catch (e) {}
        }
    }

    Process {
        id: starter

        command: ["systemctl", "--user", "start", "--no-block", "updates-check-now.service"]
        onExited: pollEnd.restart()
    }

    // The unit may fail before writing status (e.g. nix missing): stop spinning.
    Timer {
        id: pollEnd

        interval: 600000
        onTriggered: root.checking = false
    }
}
