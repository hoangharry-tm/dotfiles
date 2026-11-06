pragma Singleton

import QtQuick
import Quickshell

// Launcher brain: turns the search text into a mode and a list of result
// items { id, title, subtitle, icon | glyph, run }. UI files only render these.
//   (none) apps + inline calculator   > run in terminal   = calculator   : wallpapers
Singleton {
    id: root

    // Text the launcher opens with (e.g. ":" for the wallpaper picker via IPC).
    property string seed: ""

    readonly property var modes: ({
            apps: { label: "Apps", placeholder: "Search apps", glyph: "󰍉" },
            run: { label: "Run", placeholder: "Command to run in a terminal", glyph: "󰆍" },
            calc: { label: "Calculator", placeholder: "Calculate", glyph: "󰃬" },
            wall: { label: "Wallpapers", placeholder: "Filter wallpapers", glyph: "󰸉" }
        })

    function parse(text) {
        const m = { ">": "run", "=": "calc", ":": "wall" }[text[0]];
        return m ? { mode: m, query: text.slice(1).trim() } : { mode: "apps", query: text.trim() };
    }

    function calcItem(expr) {
        const v = Calc.evaluate(expr);
        if (!v)
            return null;
        return { id: "calc", title: v, subtitle: expr + "  ·  Enter to copy", glyph: "󰃬", run: () => { Quickshell.clipboardText = v; } };
    }

    function items(p) {
        switch (p.mode) {
        case "run":
            return p.query ? [{ id: "run", title: p.query, subtitle: "Run in terminal", glyph: "󰆍", run: () => Quickshell.execDetached(["alacritty", "--hold", "-e", "sh", "-c", p.query]) }] : [];
        case "calc":
            return [calcItem(p.query)].filter(x => x);
        case "wall":
            return Wallpapers.filter(p.query).map(f => ({ id: f.path, title: f.name, image: f.thumb, run: () => Wallpapers.apply(f.path) }));
        default:
            const apps = Apps.search(p.query);
            const c = p.query && Calc.looksLikeMath(p.query) ? calcItem(p.query) : null;
            return c ? [c, ...apps] : apps;
        }
    }
}
