pragma Singleton

import QtQuick
import Quickshell
import qs.Common

// Dock brain: which apps to show, what clicking them does, and the
// reveal/hide state. The UI (Modules/Dock) only renders `build()` output.
// Idle cost: the only timer runs while the dock is revealed and unhovered.
Singleton {
    id: root

    // Built-in entries with no .desktop file; stored in the pin list as "@id".
    readonly property var specials: ({
            "@settings": { name: "Settings", glyph: "󰒓", run: () => Panels.toggle("settings") }
        })

    // --- reveal state (per screen: only one dock is out at a time) ---
    property string screen: ""        // output whose dock is revealed
    property string edgeScreen: ""    // output whose trigger strip has the pointer
    property bool dockHover: false
    property bool menuHover: false
    property string menuKey: ""       // item whose context menu is open

    readonly property bool hot: edgeScreen === screen || dockHover || menuHover
    // Why a delay: crossing the gap between strip and dock must not flicker.
    readonly property int hideDelay: Theme.hoverOpen

    function reveal(name) {
        edgeScreen = name;
        screen = name;
    }

    function edgeLeft(name) {
        if (edgeScreen === name)
            edgeScreen = "";
    }

    Timer {
        interval: root.hideDelay
        running: root.screen !== "" && !root.hot
        onTriggered: {
            root.menuKey = "";
            root.screen = "";
        }
    }

    // --- content ---
    // Pinned apps (settings order), then running unpinned apps by window
    // age (stable: focus changes must not shuffle the dock). Windows map to
    // desktop entries like the launcher/switcher (Apps.entryFor).
    function build(windows, mru, pinned) {
        const groups = {};
        for (const id of mru) {
            const w = windows[id];
            if (!w)
                continue;
            const entry = Apps.entryFor(w.app_id);
            const key = entry?.id ?? w.app_id ?? "";
            if (!key)
                continue;
            if (!groups[key])
                groups[key] = { entry, appId: w.app_id, wins: [] };
            groups[key].wins.push(id);   // mru order
        }
        const focused = Niri.focusedWindowId;
        const make = (key, entry, appId, pin) => {
            const special = specials[key] ?? null;
            const wins = groups[key]?.wins ?? [];
            delete groups[key];
            return {
                key, entry, special, wins, pinned: pin,
                name: special?.name ?? entry?.name ?? appId,
                glyph: special?.glyph ?? "",
                icon: special ? "" : Apps.iconFor(appId, entry),
                running: wins.length > 0,
                focused: wins.includes(focused)
            };
        };
        const out = [];
        for (const id of pinned) {
            const entry = specials[id] ? null : Apps.entryFor(id);
            if (specials[id] || entry)
                out.push(make(entry?.id ?? id, entry, id, true));
        }
        const rest = Object.keys(groups).map(k => make(k, groups[k].entry, groups[k].appId, false));
        rest.sort((a, b) => Math.min(...a.wins) - Math.min(...b.wins));
        return out.concat(rest);
    }

    // --- actions ---
    function launch(item) {
        if (item.special)
            item.special.run();
        else if (item.entry)
            Apps.launch(item.entry);
    }

    function newWindow(item) {
        const act = item.entry?.actions.find(a => /new.?window/i.test(a.id + a.name));
        if (act)
            act.execute();
        else
            launch(item);
    }

    // Focus the most recent window; if the app is already focused, step
    // through its windows (by age) so repeated clicks cycle.
    function activate(item) {
        if (!item.running)
            return launch(item);
        let target = item.wins[0];
        if (item.focused && item.wins.length > 1) {
            const ring = item.wins.slice().sort((a, b) => a - b);
            target = ring[(ring.indexOf(Niri.focusedWindowId) + 1) % ring.length];
        }
        Niri.action("FocusWindow", { id: target });
    }

    function closeAll(item) {
        for (const id of item.wins)
            Niri.action("CloseWindow", { id });
    }

    function setPinned(list) {
        Settings.dockPinned = list;
    }

    function togglePin(item) {
        const list = Settings.dockPinned.filter(k => k !== item.key);
        setPinned(item.pinned ? list : list.concat([item.key]));
    }

    function movePin(key, dir) {
        const list = Settings.dockPinned.slice();
        const i = list.indexOf(key), j = i + dir;
        if (i < 0 || j < 0 || j >= list.length)
            return;
        [list[i], list[j]] = [list[j], list[i]];
        setPinned(list);
    }
}
