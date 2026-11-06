pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Synced lyrics for the current track from LRCLIB (media-lyrics caches per
// track in ~/.cache/quickshell/lyrics). Fetches only when something visible
// holds it (the Control Center media card) and the track changed.
Singleton {
    id: root

    property int users: 0
    property var lines: []       // [{ t: seconds, text }]
    readonly property bool found: lines.length > 0

    function hold() {
        users++;
    }
    function release() {
        users = Math.max(0, users - 1);
    }

    // Index of the line being sung (binary search; -1 before the first line).
    readonly property int index: {
        const t = Media.position + 0.15; // MPRIS lags slightly
        let lo = 0, hi = lines.length - 1, r = -1;
        while (lo <= hi) {
            const mid = (lo + hi) >> 1;
            if (lines[mid].t <= t) {
                r = mid;
                lo = mid + 1;
            } else
                hi = mid - 1;
        }
        return r;
    }
    readonly property string current: lines[index]?.text ?? ""
    readonly property string next: lines[index + 1]?.text ?? ""

    readonly property string key: Media.title ? [Media.artist, Media.title, Media.album, Math.round(Media.length)].join("\n") : ""
    property string fetchedKey: ""

    function parse(text) {
        const out = [];
        for (const raw of text.split("\n")) {
            const m = raw.match(/^((?:\[\d+:\d+(?:\.\d+)?\])+)\s*(.*)$/);
            if (!m)
                continue;
            for (const tag of m[1].match(/\[[^\]]+\]/g)) {
                const p = tag.slice(1, -1).split(":");
                out.push({ t: (+p[0]) * 60 + (+p[1]), text: m[2] });
            }
        }
        return out.sort((a, b) => a.t - b.t);
    }

    function refresh() {
        if (users <= 0 || key === "" || key === fetchedKey)
            return;
        fetchedKey = key;
        lines = [];
        proc.running = false;
        proc.running = true;
    }
    onUsersChanged: refresh()
    onKeyChanged: refresh()

    Process {
        id: proc

        command: ["media-lyrics", Media.artist, Media.title, Media.album, String(Math.round(Media.length))]
        stdout: StdioCollector {
            onStreamFinished: root.lines = root.parse(text)
        }
        // Network failure: forget the key so the next open retries.
        onExited: code => {
            if (code !== 0)
                root.fetchedKey = "";
        }
    }
}
