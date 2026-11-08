pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// State of the `backup` script's JSON (modules/backup.nix). `present` is the
// "backups enabled" marker; `attention` is true only when the user should look:
// the last run failed or the last success is older than staleDays.
Singleton {
    id: root

    readonly property string dir: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/backup"
    readonly property real staleDays: 3
    property bool present: false
    property bool ok: true
    property real last: 0
    property real now: Date.now() / 1000
    readonly property bool stale: last > 0 && (now - last) / 86400 > staleDays
    readonly property bool attention: present && (!ok || stale)

    function ago(secs) {
        if (secs <= 0)
            return "never";
        const d = Math.max(0, root.now - secs);
        if (d < 3600)
            return "just now";
        if (d < 86400)
            return Math.floor(d / 3600) + " h ago";
        return Math.floor(d / 86400) + " d ago";
    }

    Timer {
        interval: 600000
        running: root.present
        repeat: true
        onTriggered: root.now = Date.now() / 1000
    }

    FileView {
        path: root.dir + "/enabled"
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.present = true
        onLoadFailed: root.present = false
    }

    FileView {
        path: root.dir + "/status.json"
        printErrors: false // absent until the first run
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const s = JSON.parse(text());
                root.ok = s.ok;
                root.last = s.lastSuccess;
                root.now = Date.now() / 1000;
            } catch (e) {}
        }
    }
}
