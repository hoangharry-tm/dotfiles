pragma Singleton

import QtQuick
import Quickshell
import qs.Common

// Launcher brain: turns the search text into a mode and a list of result
// items { id, title, subtitle, icon | glyph, run }. UI files only render these.
//   (none) apps + inline calculator   > run in terminal   = calculator   : wallpapers
//   < clipboard history   . emoji   / files   ? web search (?g ?gh ?yt ?nix ?w)
Singleton {
    id: root

    // Text the launcher opens with (e.g. ":" for the wallpaper picker via IPC).
    property string seed: ""

    readonly property var modes: ({
            apps: { label: "Apps", placeholder: "Search apps", glyph: "󰍉" },
            run: { label: "Run", placeholder: "Command to run in a terminal", glyph: "󰆍" },
            calc: { label: "Calculator", placeholder: "Calculate", glyph: "󰃬" },
            wall: { label: "Wallpapers", placeholder: "Filter wallpapers", glyph: "󰸉" },
            clip: { label: "Clipboard", placeholder: "Search clipboard history", glyph: "󰅍" },
            emoji: { label: "Emoji", placeholder: "Search emoji by name", glyph: "󰞅" },
            file: { label: "Files", placeholder: "Search files in ~ (empty: recent)", glyph: "󰈔" },
            web: { label: "Web", placeholder: "Search the web (?g ?gh ?yt ?nix ?w)", glyph: "󰖟" }
        })

    function parse(text) {
        const m = { ">": "run", "=": "calc", ":": "wall", "<": "clip", ".": "emoji", "/": "file", "?": "web" }[text[0]];
        return m ? { mode: m, query: text.slice(1).trim() } : { mode: "apps", query: text.trim() };
    }

    // Starts the async side of a query (fd, qalc); called whenever it changes.
    // Items then re-render reactively from the services' result properties.
    function update(p) {
        if (p.mode === "file")
            FileSearch.setQuery(p.query);
        const local = p.mode === "calc" || p.mode === "apps" ? Calc.evaluate(p.query) : "x";
        // qalc only for what the built-in parser can't do (units, currency).
        const wantsQalc = !local && p.query && (p.mode === "calc" || Calc.looksLikeUnits(p.query));
        Calc.ask(wantsQalc ? p.query : "");
    }

    function calcItem(expr) {
        const v = Calc.evaluate(expr) || Calc.remote(expr);
        if (!v)
            return null;
        return { id: "calc", title: v, subtitle: expr + "  ·  Enter to copy", glyph: "󰃬", run: () => { Quickshell.clipboardText = v; } };
    }

    // Actions offered in the apps list when the query matches a keyword.
    readonly property var actions: [
        { id: "pick-color", title: "Pick colour", subtitle: "Sample a pixel, copy its hex", glyph: "󰴱", keywords: "pick colour color picker eyedropper hex", run: () => Quickshell.execDetached(["pick-color"]) },
        // Deferred: the launcher closes the open panel right after run().
        { id: "settings", title: "Settings", subtitle: "Shell preferences", glyph: "󰒓", keywords: "settings preferences options config", run: () => Qt.callLater(() => Panels.toggle("settings")) },
        { id: "files", title: "Files", subtitle: "Browse files with yazi", glyph: "󰉋", keywords: "files file manager yazi browse folder", run: () => Quickshell.execDetached(["alacritty", "--class", "yazi", "-e", "yazi"]) },
        { id: "screen-ocr", title: "Copy text from screen", subtitle: "Select a region, OCR it (eng + vie)", glyph: "󰊄", keywords: "copy text screen ocr tesseract recognize", run: () => Quickshell.execDetached(["screen-ocr"]) },
        { id: "screen-qr", title: "Scan QR code", subtitle: "Select a region, decode the QR code", glyph: "󰐲", keywords: "scan qr code barcode zbar", run: () => Quickshell.execDetached(["screen-qr"]) }
    ]

    function actionItems(query) {
        const terms = query.toLowerCase().split(/\s+/).filter(t => t);
        return terms.length ? actions.filter(a => terms.every(t => a.keywords.includes(t))) : [];
    }

    function items(p) {
        switch (p.mode) {
        case "run":
            return p.query ? [{ id: "run", title: p.query, subtitle: "Run in terminal", glyph: "󰆍", run: () => Quickshell.execDetached(["alacritty", "--hold", "-e", "sh", "-c", p.query]) }] : [];
        case "calc":
            return [calcItem(p.query)].filter(x => x);
        case "file":
            return FileSearch.items();
        case "web":
            return WebSearch.items(p.query);
        case "wall":
            return Wallpapers.filter(p.query).map(f => ({ id: f.path, title: f.name, image: f.thumb, run: () => Wallpapers.apply(f.path) }));
        case "clip":
            return Clipboard.filter(p.query).map(e => ({ id: e.line, title: e.text, subtitle: e.image ? "Image" : "", glyph: e.image ? "󰋩" : "󰅍", run: () => Clipboard.copy(e), remove: () => Clipboard.remove(e) }));
        case "emoji":
            return Emoji.filter(p.query);
        default:
            const apps = Apps.search(p.query);
            const c = p.query && (Calc.looksLikeMath(p.query) || Calc.looksLikeUnits(p.query)) ? calcItem(p.query) : null;
            return [...(c ? [c] : []), ...actionItems(p.query), ...apps];
        }
    }
}
