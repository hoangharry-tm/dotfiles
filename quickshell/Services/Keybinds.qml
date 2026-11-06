pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Parses niri's binds.kdl (the single source of truth) into display groups:
//   groups = [{ name, rows: [{ label, tokens: [string, …], search }] }]
// `tokens` is the row's keys flattened for rendering; "/" separates
// alternatives (e.g. Mod ←↑↓→ / HJKL).
// Line-based on purpose: the file has one bind per line and `// Section`
// comments, so no KDL parser is needed. Parsed once per file change; the UI
// only calls filter(), which is a cheap substring match.
Singleton {
    id: root

    property var groups: []

    // Search: every whitespace-separated term must appear in a row's text.
    function filter(query) {
        const terms = query.toLowerCase().split(/\s+/).filter(t => t);
        if (terms.length === 0)
            return groups;
        return groups.map(g => ({
                    name: g.name,
                    rows: g.rows.filter(r => terms.every(t => r.search.includes(t)))
                })).filter(g => g.rows.length > 0);
    }

    // ---- display tables -------------------------------------------------

    readonly property var modGlyph: ({ Mod: "❖", Super: "❖", Shift: "⇧", Ctrl: "⌃", Alt: "⌥" })

    readonly property var keyName: ({
            Return: "↵", Escape: "Esc", Tab: "⇥", Space: "Space", Delete: "Del",
            Grave: "`", Minus: "−", Equal: "=", Slash: "∕", // U+2215: looks like "/" but isn't the "/" alternatives separator Comma: ",", Period: ".",
            BracketLeft: "[", BracketRight: "]", Print: "PrtSc",
            Left: "←", Right: "→", Up: "↑", Down: "↓",
            Page_Up: "PgUp", Page_Down: "PgDn",
            XF86AudioRaiseVolume: "Vol +", XF86AudioLowerVolume: "Vol −",
            XF86AudioMute: "Mute", XF86AudioMicMute: "Mic mute",
            XF86AudioPlay: "Play", XF86AudioStop: "Stop",
            XF86AudioPrev: "Prev", XF86AudioNext: "Next",
            XF86MonBrightnessUp: "Bright +", XF86MonBrightnessDown: "Bright −"
        })

    // Keys that merge into one row when their actions only differ by a
    // trailing direction (focus-column-left/-right, …) or number (workspaces
    // 1..9). `both` is the label when every key of the class is present.
    readonly property var classes: [
        { id: "arrows", fam: "dir", keys: ["Left", "Up", "Down", "Right"], glyphs: ["←", "↑", "↓", "→"], sep: "" },
        { id: "hjkl", fam: "dir", keys: ["H", "J", "K", "L"], sep: "" },
        { id: "pg", fam: "page", keys: ["Page_Up", "Page_Down"], glyphs: ["PgUp", "PgDn"], sep: "·" },
        { id: "ui", fam: "page", keys: ["U", "I"], sep: "·" },
        { id: "wheelv", fam: "wheelv", keys: ["WheelScrollUp", "WheelScrollDown"], glyphs: ["Scroll ↑", "Scroll ↓"], both: "Scroll ↕" },
        { id: "wheelh", fam: "wheelh", keys: ["WheelScrollLeft", "WheelScrollRight"], glyphs: ["Scroll ←", "Scroll →"], both: "Scroll ↔" },
        { id: "num", fam: "num", keys: ["1", "2", "3", "4", "5", "6", "7", "8", "9"], sep: ",", both: "1…9" }
    ]

    // Friendly names for `qs ipc call shell <fn>` and for spawn-sh commands.
    readonly property var shellIpc: ({ launcher: "App launcher", wallpapers: "Wallpapers", control: "Control Center", calendar: "Calendar", power: "Power menu", keybinds: "Keybindings" })
    readonly property var shellCmds: [
        [/set-volume.*\+/, "Volume up"],
        [/set-volume/, "Volume down"],
        [/set-mute.*SINK/, "Mute"],
        [/set-mute.*SOURCE/, "Mute microphone"],
        [/play-pause/, "Play / pause"],
        [/playerctl stop/, "Stop"],
        [/previous/, "Previous track"],
        [/next/, "Next track"]
    ]

    // ---- parsing ----------------------------------------------------------

    readonly property var keyClass: {
        const m = {};
        for (const c of classes)
            c.keys.forEach((k, i) => m[k] = { c, i });
        return m;
    }

    function humanise(s) {
        // Only join hyphenated words ("focus-column" → "focus column"); keep a
        // leading minus on values like "-10%".
        const t = s.replace(/(\w)[-_]+(?=\w)/g, "$1 ").trim();
        return t.charAt(0).toUpperCase() + t.slice(1);
    }

    function labelOf(action, args) {
        if (action === "spawn") {
            if (args[0] === "qs" && args[1] === "ipc" && args[2] === "call")
                return args[3] === "shell" && shellIpc[args[4]] || humanise(args[3] + " " + args[4]);
            return humanise(args[0].split("/").pop());
        }
        if (action === "spawn-sh")
            return (shellCmds.find(c => c[0].test(args[0])) || [0, humanise(args[0].split(" ")[0])])[1];
        return humanise([action, ...args].join(" "));
    }

    // Shared prefix + differing last words: ["focus-column","focus-window"] -> "Focus column / window".
    function joinStems(stems) {
        const w = stems.map(s => s.split("-"));
        const head = w[0].slice(0, -1).join("-");
        const sameHead = w.every(x => x.length === w[0].length && x.slice(0, -1).join("-") === head);
        return humanise(sameHead && w.length > 1 ? head + "-" + w.map(x => x[x.length - 1]).join(" / ") : stems.join(" / "));
    }

    // The key part of one combo (class members collapse, e.g. "←↑↓→").
    function keyText(cb) {
        if (!cb.c)
            return keyName[cb.key] || cb.key;
        const c = cb.c, idx = [...cb.seen].sort((a, b) => a - b);
        return c.both && idx.length === c.keys.length ? c.both : idx.map(i => c.glyphs ? c.glyphs[i] : c.keys[i]).join(c.sep ?? "");
    }

    // Combos sharing modifiers merge ("Mod ←↑↓→ / HJKL"); others follow after a "/".
    function rowTokens(combos) {
        const byMods = new Map();
        for (const cb of combos) {
            const k = cb.mods.join("+");
            if (!byMods.has(k))
                byMods.set(k, { mods: cb.mods.map(m => modGlyph[m] || m), keys: [] });
            byMods.get(k).keys.push(keyText(cb));
        }
        const out = [];
        for (const g of byMods.values()) {
            if (out.length)
                out.push("/");
            out.push(...g.mods);
            g.keys.forEach((k, i) => out.push(...(i ? ["/", k] : [k])));
        }
        return out;
    }

    function parse(src) {
        const out = [];
        let group = { name: "", map: new Map(), rows: [] };
        let inBinds = false, prevComment = false;
        out.push(group);

        for (const raw of src.split("\n")) {
            const line = raw.trim();
            if (!inBinds) {
                inBinds = /^binds\s*\{/.test(line);
                continue;
            }
            if (line.startsWith("//")) {
                // Only the first comment line after a gap names a section;
                // the rest are notes. Cut parenthetical/explanatory tails.
                if (!prevComment) {
                    const name = line.replace(/^\/\/\s*/, "").split(/\s*(?:\(|;|\.|\svia\s|\s[—-]\s)/)[0];
                    if (group.rows.length > 0)
                        out.push(group = { name, map: new Map(), rows: [] });
                    else
                        group.name = name;
                }
                prevComment = true;
                continue;
            }
            prevComment = false;

            const open = line.indexOf("{");
            if (open < 1 || !line.endsWith("}") || line.length === open + 1)
                continue;
            const spec = line.slice(0, open).trim().split(/\s+/)[0].split("+");
            const props = line.slice(0, open);
            // QML's JS engine has no matchAll.
            const toks = [], re = /"([^"]*)"|[^\s";]+/g;
            for (let m; (m = re.exec(line.slice(open + 1, -1)));)
                toks.push(m[1] ?? m[0]);
            const title = props.match(/hotkey-overlay-title=(?:"([^"]*)"|(null))/);
            // Skip hidden binds, our own overlay, and hardware keys (their keycaps say it all).
            if (!toks.length || toks[0] === "show-hotkey-overlay" || title?.[2] || spec[spec.length - 1].startsWith("XF86"))
                continue;

            const [action, ...args] = toks;
            const key = spec.pop();
            const mods = spec.map(m => m === "Super" ? "Mod" : m);
            const hit = keyClass[key];
            const stem = action.replace(/-(left|right|up|down)$/, "");
            // Class merging only applies when the action really is a directional/numbered family.
            const fam = hit && (hit.c.fam === "num" ? /^\d+$/.test(args[0] ?? "") : stem !== action) ? hit : null;
            const label = title?.[1] ?? (fam ? null : labelOf(action, args));
            const rowKey = fam ? mods.join("+") + "|" + fam.c.fam : label.toLowerCase();

            let row = group.map.get(rowKey);
            if (!row) {
                row = { label, stems: [], combos: new Map(), raw: [] };
                group.map.set(rowKey, row);
                group.rows.push(row);
            }
            if (fam && !row.stems.includes(stem))
                row.stems.push(stem);
            row.raw.push(...spec, key);
            const ck = fam ? mods.join("+") + "|" + fam.c.id : mods.join("+") + "|" + key;
            let cb = row.combos.get(ck);
            if (!cb)
                row.combos.set(ck, cb = { mods, key, c: fam?.c, seen: new Set() });
            if (fam)
                cb.seen.add(fam.i);
        }

        return out.filter(g => g.rows.length > 0).map(g => ({
                    name: g.name,
                    rows: g.rows.map(r => {
                        const label = r.label ?? joinStems(r.stems);
                        const tokens = rowTokens([...r.combos.values()]);
                        return { label, tokens, search: (label + " " + r.raw.join(" ") + " super " + tokens.join(" ")).toLowerCase() };
                    })
                }));
    }

    FileView {
        path: Quickshell.env("HOME") + "/.config/niri/binds.kdl"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.groups = root.parse(text())
    }
}
