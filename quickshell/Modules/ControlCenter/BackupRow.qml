import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets

// "Last backup: 2 d ago" / "Backups off". Reads the JSON written by the
// `backup` script; hidden unless backups are enabled (marker file exists).
Section {
    id: root

    readonly property string dir: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/backup"
    property bool ok: true
    property real last: 0
    property real now: Date.now() / 1000

    visible: marker.present

    // Minute tick keeps "x ago" fresh without rereading the file.
    Timer {
        interval: 60000
        running: root.visible
        repeat: true
        onTriggered: root.now = Date.now() / 1000
    }

    FileView {
        id: marker

        path: root.dir + "/enabled"
        property bool present: false
        printErrors: false
        watchChanges: true
        onLoaded: present = true
        onLoadFailed: present = false
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
            } catch (e) {}
        }
    }

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

    InfoRow {
        glyph: root.ok ? "󰁯" : "󰀦"
        label: "Last backup"
        value: root.ok ? root.ago(root.last) : "failed, " + root.ago(root.last)
        valueColor: root.ok ? Theme.text : Theme.error
    }
}
