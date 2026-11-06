pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history from cliphist (the watcher is a systemd user service,
// modules/desktop-tools.nix). Lines are "<id>\t<preview>"; images have a
// "[[ binary data ... ]]" preview and show as a label instead of a thumbnail
// (decoding per row would cost a process each).
Singleton {
    id: root

    readonly property int limit: 200 // newest first; keeps the list light
    property var entries: [] // [{ line, text, image }]

    function refresh() {
        list.running = true;
    }

    function filter(query) {
        const q = query.trim().toLowerCase();
        return q ? entries.filter(e => e.text.toLowerCase().includes(q)) : entries;
    }

    function copy(entry) {
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist decode | paste-into", "sh", entry.line]);
    }

    function remove(entry) {
        entries = entries.filter(e => e !== entry); // instant; cliphist catches up
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist delete", "sh", entry.line]);
    }

    Process {
        id: list

        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.entries = text.split("\n").filter(l => l).slice(0, root.limit).map(line => {
                    const preview = line.slice(line.indexOf("\t") + 1).trim();
                    const image = /^\[\[ binary data/.test(preview);
                    return { line: line, image: image, text: image ? "[image] " + preview.replace(/^\[\[ binary data |\]\]$/g, "").trim() : preview };
                })
        }
    }
}
