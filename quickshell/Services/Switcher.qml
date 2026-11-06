pragma Singleton

import QtQuick
import Quickshell
import qs.Common
import qs.Services

// Alt+Tab state. niri binds call `qs ipc call switcher next|prev`; the
// window (Modules/Switcher) only exists while `open` (LazyLoader).
Singleton {
    id: root

    property bool open: false
    property var items: []          // window snapshot, MRU order (frozen while open)
    property int index: 0
    property bool hasFocus: false   // set by the window once it holds keyboard focus
    property string screen: ""

    // Why: Alt can be released before the layer surface maps and gets keys;
    // then no release event ever arrives, so treat it as a quick tap.
    Timer {
        id: grace

        interval: 250
        onTriggered: if (root.open && !root.hasFocus) root.commit()
    }

    function snapshot() {
        const ids = Niri.mru.filter(id => Niri.windows[id]);
        return ids.map(id => Niri.windows[id]);
    }

    function step(dir) {
        if (!open) {
            items = snapshot();
            if (!items.length)
                return;
            screen = Panels.focusedScreen();
            hasFocus = false;
            // MRU[0] is the current window, so "next" starts on the previous one.
            index = items.length > 1 ? (dir > 0 ? 1 : items.length - 1) : 0;
            open = true;
            grace.restart();
            return;
        }
        index = (index + dir + items.length) % items.length;
    }

    function pick(i) {
        index = i;
        commit();
    }

    function commit() {
        const w = items[index];
        close();
        if (w)
            Niri.action("FocusWindow", { id: w.id });
    }

    function close() {
        grace.stop();
        open = false;
        hasFocus = false;
    }

    // "Workspace 2 · DP-1" (output only when it disambiguates).
    function caption(w) {
        const ws = Niri.workspaces.find(x => x.id === w.workspace_id);
        if (!ws)
            return "";
        const multi = new Set(Niri.workspaces.map(x => x.output)).size > 1;
        return (ws.name ?? ("Workspace " + ws.idx)) + (multi ? " · " + ws.output : "");
    }
}
