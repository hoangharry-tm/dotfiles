pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Emoji list built by Nix from nixpkgs' Unicode data (modules/desktop-tools.nix)
// as "emoji<TAB>name" lines. Items are built once, so typing only filters.
Singleton {
    id: root

    property var all: [] // [{ id, title, emoji, run }]

    function filter(query) {
        const terms = query.toLowerCase().split(/\s+/).filter(t => t);
        return terms.length ? all.filter(e => terms.every(t => e.search.includes(t))) : all;
    }

    // First emoji open only; the parsed list is then kept.
    function load() {
        if (all.length === 0)
            read.running = true;
    }

    Process {
        id: read

        command: ["cat", Quickshell.env("HOME") + "/.local/share/quickshell/emoji.tsv"]
        stdout: StdioCollector {
            onStreamFinished: root.all = text.split("\n").filter(l => l).map(l => {
                    const [emoji, name] = l.split("\t");
                    return { id: emoji, title: name, emoji: emoji, search: name.toLowerCase(), run: () => Quickshell.execDetached(["sh", "-c", "printf %s \"$1\" | paste-into", "sh", emoji]) };
                })
        }
    }
}
