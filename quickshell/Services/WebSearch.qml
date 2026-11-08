pragma Singleton

import QtQuick
import Quickshell

// `?` mode: open a web search with xdg-open. All engines live in this one
// table; `?<key> terms` picks one, plain `? terms` uses defaultEngine.
Singleton {
    id: root

    readonly property string defaultEngine: "ddg"   // change the default here
    // url: %s is replaced with the URL-encoded query. home: opened for an empty query.
    readonly property var engines: ({
            ddg: { name: "DuckDuckGo", url: "https://duckduckgo.com/?q=%s", home: "https://duckduckgo.com" },
            g: { name: "Google", url: "https://www.google.com/search?q=%s", home: "https://www.google.com" },
            gh: { name: "GitHub", url: "https://github.com/search?q=%s", home: "https://github.com" },
            yt: { name: "YouTube", url: "https://www.youtube.com/results?search_query=%s", home: "https://www.youtube.com" },
            nix: { name: "NixOS packages", url: "https://search.nixos.org/packages?query=%s", home: "https://search.nixos.org/packages" },
            w: { name: "Wikipedia", url: "https://en.wikipedia.org/w/index.php?search=%s", home: "https://en.wikipedia.org" }
        })

    function open(url) {
        Apps.run(["xdg-open", url]);
    }

    // "gh foo bar" -> { key: "gh", terms: "foo bar" }; unknown first word = default engine.
    function split(q) {
        const m = /^(\S+)(?:\s+(.*))?$/.exec(q);
        if (m && engines.hasOwnProperty(m[1]))
            return { key: m[1], terms: (m[2] ?? "").trim() };
        return { key: defaultEngine, terms: q };
    }

    function items(q) {
        const s = split(q);
        const e = engines[s.key];
        if (s.terms)
            return [{ id: "web", title: s.terms, subtitle: e.name, glyph: "language", run: () => open(e.url.replace("%s", encodeURIComponent(s.terms))) }];
        // Nothing typed yet: list engines so the sub-prefixes are discoverable.
        return Object.keys(engines).map(k => ({ id: "web-" + k, title: engines[k].name, subtitle: (k === defaultEngine ? "?  ·  " : "") + "?" + k + " <terms>", glyph: "language", run: () => open(engines[k].home) }));
    }
}
