pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history for the launcher's `<` mode. Sources:
//  - cliphist (watcher = systemd user service, modules/desktop-tools.nix).
//    `cliphist list` gives "<id>\t<preview>" with whitespace collapsed, ~100
//    chars, and no timestamps (so no relative times); it runs only when the
//    mode opens. Full text / image bytes are decoded lazily for the ONE
//    selected entry.
//  - pins: ~/.local/state/quickshell/clipboard-pins.json, full text kept
//    here so pins survive cliphist's own limits and wipes.
// Items handed to the launcher: { id, title, kind, entry, run, alt, remove, pin, open }.
Singleton {
    id: root

    readonly property int limit: 200 // newest first; keeps the list light
    readonly property string thumbDir: Quickshell.env("HOME") + "/.cache/quickshell/cliphist-thumbs"
    readonly property var kinds: ({
            text: { label: "Text", glyph: "󰈙" },
            link: { label: "Link", glyph: "󰌹" },
            color: { label: "Colour", glyph: "󰏘" },
            code: { label: "Code", glyph: "󰅩" },
            path: { label: "Path", glyph: "󰉋" },
            image: { label: "Image", glyph: "󰋩" }
        })
    // `<url foo` style sub-prefixes: first word picks a type filter.
    readonly property var aliases: ({ text: "text", txt: "text", url: "link", link: "link", color: "color", colour: "color", col: "color", code: "code", path: "path", file: "path", img: "image", image: "image", pin: "pin" })

    property var history: [] // parsed cliphist entries, newest first
    property var pins: [] // [{ full, kind }]
    property bool confirmClear: false // first Ctrl+Shift+Del arms, second wipes

    // What the preview pane shows (selected entry); filled lazily.
    property var inspected: null
    property string inspectedText: ""
    property string inspectedThumb: ""
    property var textCache: ({}) // id -> full text (bounded by the 200-entry list)

    // ---- detection -----------------------------------------------------------
    readonly property var reUrl: /^(https?|ftp):\/\/\S+$/i
    readonly property var reHex: /^#(?:[0-9a-f]{3,4}|[0-9a-f]{6}|[0-9a-f]{8})$/i
    readonly property var reRgb: /^rgba?\(\s*\d{1,3}\s*[, ]\s*\d{1,3}\s*[, ]\s*\d{1,3}\s*(?:[,\/]\s*[\d.]+%?\s*)?\)$/i
    readonly property var rePath: /^(~|\.{0,2})\/[^\s]*(\s[^\s\/]+)*$/
    // Previews collapse newlines, so code is guessed from punctuation/keywords.
    readonly property var reCode: /[{};]\s|;$|=>|->|\b(function|def|class|const|let|var|import|return|SELECT|#include|fn|impl|pub)\b.*[({=:]|<\/?\w+[^>]*>|\$\(|&&|\|\|/

    function detect(t) {
        const s = t.trim();
        if (reUrl.test(s))
            return "link";
        if (reHex.test(s) || reRgb.test(s))
            return "color";
        if (rePath.test(s) && s.length > 1)
            return "path";
        return reCode.test(s) ? "code" : "text";
    }

    // CSS colour -> Qt "#aarrggbb"/"#rrggbb" (CSS puts alpha last, Qt first).
    function toColor(s) {
        const t = s.trim();
        if (reHex.test(t)) {
            const h = t.slice(1);
            const x = h.length <= 4 ? h.replace(/./g, c => c + c) : h;
            return x.length === 8 ? "#" + x.slice(6) + x.slice(0, 6) : "#" + x;
        }
        const n = t.match(/[\d.]+/g);
        if (!n || n.length < 3)
            return "";
        const a = n[3] === undefined ? 1 : Math.min(1, +n[3] / (t.includes("%") ? 100 : 1));
        return Qt.rgba(Math.min(255, +n[0]) / 255, Math.min(255, +n[1]) / 255, Math.min(255, +n[2]) / 255, a).toString();
    }

    function domain(url) {
        const m = url.match(/^\w+:\/\/([^\/?#:]+)/);
        return m ? m[1].replace(/^www\./, "") : "";
    }

    // Collapse whitespace the way cliphist's preview does, for pin/history dedupe.
    function norm(s) {
        return s.replace(/\s+/g, " ").trim();
    }

    // ---- list ----------------------------------------------------------------
    function refresh() {
        list.running = true;
        // Thumbs are a cache: drop week-old ones whenever the mode opens.
        Quickshell.execDetached(["find", thumbDir, "-type", "f", "-mtime", "+7", "-delete"]);
    }

    function parseLine(line) {
        const tab = line.indexOf("\t");
        const preview = line.slice(tab + 1).trim();
        const image = /^\[\[ binary data/.test(preview);
        const meta = image ? preview.replace(/^\[\[ binary data |\]\]$/g, "").trim() : "";
        const dims = meta.match(/(\w+) (\d+x\d+)$/);
        return {
            key: line,
            id: line.slice(0, tab),
            line: line,
            pinned: false,
            image: image,
            kind: image ? "image" : detect(preview),
            text: image ? "Image " + (dims ? dims[2] : "") : preview,
            meta: meta.replace(/ \d+x\d+$/, "")
        };
    }

    // Pinned entries first; history entries a pin already covers are hidden.
    readonly property var pinEntries: pins.map(p => ({ key: "pin:" + p.full, id: "", line: "", pinned: true, image: false, kind: p.kind, text: norm(p.full), full: p.full, meta: "" }))

    function all() {
        const covered = new Set(pinEntries.map(p => p.text.slice(0, 100)));
        return [...pinEntries, ...history.filter(e => !covered.has(e.text.replace(/…$/, "").slice(0, 100)))];
    }

    // Returns { kind, q } from the raw query ("img cat" -> image, "cat").
    function parseQuery(query) {
        const m = query.trim().match(/^(\S+)(?:\s+(.*))?$/);
        const kind = m ? aliases[m[1].toLowerCase()] : undefined;
        return kind ? { kind: kind, q: (m[2] ?? "").toLowerCase() } : { kind: "", q: query.trim().toLowerCase() };
    }

    function chipLabel(query) {
        const k = parseQuery(query).kind;
        return k ? "Clipboard · " + (k === "pin" ? "Pinned" : kinds[k].label) : "Clipboard";
    }

    function items(query) {
        const f = parseQuery(query);
        let rows = all().filter(e => !f.kind || (f.kind === "pin" ? e.pinned : e.kind === f.kind));
        if (f.q) {
            // Fuzzy score (shared with the app search); best first, ties keep recency.
            rows = rows.map(e => ({ e, s: Apps.fuzzy(f.q, e.text.toLowerCase()) })).filter(r => r.s >= 0).sort((a, b) => b.s - a.s).map(r => r.e);
        }
        return rows.map(e => ({ id: e.key, title: e.text, kind: e.kind, entry: e, run: () => paste(e), alt: () => copyOnly(e), remove: () => remove(e), pin: () => togglePin(e), open: () => openIt(e) }));
    }

    // ---- actions -------------------------------------------------------------
    // Pinned text goes through stdin; history through `cliphist decode`.
    function pipeFrom(e) {
        return e.pinned ? "printf '%s' \"$1\"" : "printf '%s' \"$1\" | cliphist decode";
    }

    function run(e, sink) {
        Quickshell.execDetached(["sh", "-c", pipeFrom(e) + " | " + sink, "sh", e.pinned ? e.full : e.line]);
    }

    function paste(e) {
        run(e, "paste-into");
    }

    function copyOnly(e) {
        run(e, "wl-copy >/dev/null 2>&1"); // wl-copy forks a server; detach its fds
    }

    function remove(e) {
        if (e.pinned) {
            unpin(e);
            return;
        }
        history = history.filter(x => x !== e); // instant; cliphist catches up
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist delete", "sh", e.line]);
    }

    // Opens the first line of a link/path (pins: stored text; history: decode).
    function openIt(e) {
        if (e.kind !== "link" && e.kind !== "path")
            return false;
        Quickshell.execDetached(["sh", "-c", pipeFrom(e) + " | head -n1 | { IFS= read -r p; case $p in '~'*) p=$HOME${p#'~'};; esac; xdg-open \"$p\"; }", "sh", e.pinned ? e.full : e.line]);
        return true;
    }

    function clearAll() {
        confirmClear = false;
        history = [];
        textCache = {};
        Quickshell.execDetached(["sh", "-c", "cliphist wipe; rm -rf \"$1\"", "sh", thumbDir]); // pins are kept
    }

    // ---- pins ----------------------------------------------------------------
    function savePins(next) {
        pins = next;
        pinFile.setText(JSON.stringify(next));
    }

    function unpin(e) {
        savePins(pins.filter(p => p.full !== e.full));
    }

    function togglePin(e) {
        if (e.pinned)
            return unpin(e);
        if (e.image)
            return; // pins hold text only
        pinJob.entry = e;
        pinJob.command = ["sh", "-c", "printf '%s' \"$1\" | cliphist decode", "sh", e.line];
        pinJob.running = true;
    }

    FileView {
        id: pinFile

        path: Settings.dir + "/clipboard-pins.json"
        blockLoading: true // pins are needed on first open
        printErrors: false // missing until the first pin
        atomicWrites: true
        onLoaded: {
            try {
                root.pins = JSON.parse(text());
            } catch (e) {}
        }
    }

    Process {
        id: pinJob

        property var entry: null

        stdout: StdioCollector {
            onStreamFinished: if (text && !root.pins.some(p => p.full === text))
                root.savePins([{ full: text, kind: pinJob.entry.kind }, ...root.pins])
        }
    }

    // ---- preview (selected entry only) -----------------------------------------
    // Debounced: holding an arrow key must not spawn a decode per row.
    function inspect(entry) {
        if (entry === inspected)
            return;
        inspected = entry;
        inspectedText = entry?.pinned ? entry.full : (entry && textCache[entry.id]) || "";
        inspectedThumb = "";
        settle.restart();
    }

    function load() {
        const e = inspected;
        if (!e || e.pinned || loadJob.running)
            return; // a finished job re-checks, so a late selection still loads
        if (e.image) {
            // Cached by id (ids only grow), so each image is decoded once.
            loadJob.command = ["sh", "-c", "f=\"$1/$2.png\"; [ -s \"$f\" ] || { mkdir -p \"$1\" && cliphist decode \"$2\" > \"$f.tmp\" && mv \"$f.tmp\" \"$f\"; }; printf '%s' \"$f\"", "sh", thumbDir, e.id];
        } else if (textCache[e.id] === undefined) {
            loadJob.command = ["sh", "-c", "cliphist decode \"$1\" | head -c 6000", "sh", e.id];
        } else {
            return;
        }
        loadJob.loading = e;
        loadJob.running = true;
    }

    Timer {
        id: settle

        interval: 60
        onTriggered: root.load()
    }

    Process {
        id: loadJob

        property var loading: null

        stdout: StdioCollector {
            onStreamFinished: {
                const e = loadJob.loading;
                if (e.image) {
                    if (root.inspected === e)
                        root.inspectedThumb = text;
                } else {
                    root.textCache[e.id] = text;
                    if (root.inspected === e)
                        root.inspectedText = text;
                }
                Qt.callLater(root.load); // selection may have moved meanwhile
            }
        }
    }

    Process {
        id: list

        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.textCache = {};
                root.history = text.split("\n").filter(l => l).slice(0, root.limit).map(root.parseLine);
            }
        }
    }
}
