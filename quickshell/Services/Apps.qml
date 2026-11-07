pragma Singleton

import QtQuick
import Quickshell

// Installed applications (.desktop entries) and launcher search.
// search() returns launcher result items: { id, title, subtitle, icon, run }.
Singleton {
    // The terminal for the shell's own launches (kitty; flags shared with alacritty).
    readonly property string terminal: "kitty"

    // Every app the shell starts gets its own transient systemd scope, so
    // restarting quickshell.service (switch, live edits) never kills the
    // apps it launched (it used to take terminals down with it).
    function run(argv) {
        Quickshell.execDetached(["systemd-run", "--user", "--scope", "--collect", "--quiet", "--", ...argv]);
    }
    // Desktop entry or action: its argv minus field codes (%u, %F, …), which
    // only make sense when a file/URL is passed (aerc got a literal "%u").
    function argv(entry) {
        return entry.command.filter(a => !/^%[fFuUdDnNickvm]$/.test(a));
    }
    function start(entry) {
        run(argv(entry));
    }

    id: root

    // Lowercased search fields are computed once per app-list change, not per
    // keystroke. Actions ("New Private Window") are indexed as their own rows.
    readonly property var index: {
        const out = [];
        for (const app of DesktopEntries.applications.values) {
            if (app.noDisplay)
                continue;
            const extra = [app.genericName, app.comment, ...(app.keywords ?? []), app.id].join(" ").toLowerCase();
            out.push({ kind: "app", app, id: app.id, name: app.name.toLowerCase(), extra });
            for (const act of app.actions)
                out.push({ kind: "action", app, act, id: app.id + "#" + act.id, name: act.name.toLowerCase(), extra: "" });
        }
        return out;
    }

    // Prefix > word prefix > substring > in-order subsequence ("ffx" -> Firefox).
    // Returns a score or -1.
    function fuzzy(q, s) {
        const at = s.indexOf(q);
        if (at === 0)
            return 100;
        if (at > 0)
            return /[\s\-_.]/.test(s[at - 1]) ? 80 : 60 - Math.min(at, 20) * 0.5;
        if (q.length < 2)
            return -1;
        let j = 0, run = 0, best = 0, first = -1;
        for (let i = 0; i < s.length && j < q.length; i++) {
            if (s[i] === q[j]) {
                if (first < 0)
                    first = i;
                j++;
                run++;
                best = Math.max(best, run);
            } else {
                run = 0;
            }
        }
        return j < q.length ? -1 : 20 + best * 4 - first * 0.5;
    }

    function item(e) {
        const app = e.app;
        if (e.kind === "action")
            return { id: e.id, title: e.act.name, subtitle: app.name, icon: app.icon, run: () => { Usage.record(e.id); start(e.act); } };
        return { id: e.id, title: app.name, subtitle: app.comment || app.genericName, icon: app.icon, run: () => launch(app) };
    }

    function search(query, limit = 50) {
        const q = query.trim().toLowerCase();
        const scored = [];
        for (const e of index) {
            let s;
            if (!q) {
                s = e.kind === "app" ? 0 : -1;
            } else {
                s = fuzzy(q, e.name);
                // Action rows only on a real (non-subsequence) hit, else they'd crowd the list.
                if (e.kind === "action" ? s < 60 : s < 0 && e.extra.includes(q))
                    s = e.kind === "action" ? -1 : 10;
            }
            if (s >= 0)
                scored.push({ e, s: s + Usage.boost(e.id) - (e.kind === "action" ? 5 : 0) });
        }
        scored.sort((a, b) => b.s - a.s || a.e.name.localeCompare(b.e.name));
        return scored.slice(0, limit).map(x => item(x.e));
    }

    // Window app_id -> desktop entry / icon path. Shared by the Alt+Tab
    // switcher and the dock so both resolve icons identically.
    function entryFor(appId) {
        return appId ? DesktopEntries.heuristicLookup(appId) : null;
    }

    // One icon resolver for every surface. iconPath(name, true) yields "" when
    // the theme has no such icon, and a bare absolute path when the theme
    // lookup lands on a file (Nix store icons); an Image treats that as qrc:,
    // so it becomes a file:// URL. Always returns a usable source (generic
    // fallback last), so callers never render Qt's missing-image checkerboard.
    function iconSource(name) {
        if (!name)
            return "";
        if (name.startsWith("file:") || name.startsWith("image:"))
            return name;
        if (name.startsWith("/"))
            return "file://" + name;
        const p = Quickshell.iconPath(name, true);
        return p.startsWith("/") ? "file://" + p : p;
    }

    function iconFor(appId, entry) {
        const id = appId ?? "";
        const e = entry ?? entryFor(id);
        for (const n of [e?.icon, id, id.toLowerCase(), e?.id]) {
            const s = iconSource(n);
            if (s)
                return s;
        }
        return iconSource("application-x-executable");
    }

    function launch(app) {
        Usage.record(app.id);
        if (app.runInTerminal)
            run([terminal, "-e", ...argv(app)]);
        else
            start(app);
    }
}
