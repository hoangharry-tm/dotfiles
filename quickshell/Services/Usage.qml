pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Launch history for "frecency" ranking, persisted across sessions.
// entries: { <id>: { n: launch count, t: last launch (ms since epoch) } }
Singleton {
    id: root

    readonly property var entries: store.entries
    readonly property real halfLifeDays: 14

    // 0..~30 ranking bonus: grows with log(count), halves every two weeks.
    function boost(id) {
        const e = entries[id];
        if (!e)
            return 0;
        const ageDays = (Date.now() - e.t) / 86400000;
        const weight = e.n * Math.pow(0.5, ageDays / halfLifeDays);
        return Math.min(30, 10 * Math.log2(1 + weight));
    }

    function record(id) {
        const next = Object.assign({}, entries);
        next[id] = { n: (entries[id]?.n ?? 0) + 1, t: Date.now() };
        store.entries = next;
        file.writeAdapter();
    }

    FileView {
        id: file

        path: Quickshell.statePath("launcher-usage.json")
        blockLoading: true // tiny file; ranking must be ready for the first query
        printErrors: false // missing on first run

        JsonAdapter {
            id: store

            property var entries: ({})
        }
    }
}
