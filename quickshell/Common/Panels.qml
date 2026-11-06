pragma Singleton

import QtQuick
import Quickshell
import qs.Services

// Which popout is open, and on which screen. Only one at a time, like macOS.
Singleton {
    id: root

    // "", "control", "calendar", "launcher", "power", "timer"
    property string open: ""
    property string screen: ""

    function toggle(name, screenName) {
        if (open === name && (screen === screenName || !screenName)) {
            close();
        } else {
            open = name;
            screen = screenName || focusedScreen();
        }
    }

    function close() {
        open = "";
    }

    function isOpen(name, screenName) {
        return open === name && screen === screenName;
    }

    // Screen with keyboard focus: the output of niri's focused workspace.
    function focusedScreen() {
        const ws = Niri.workspaces.find(w => w.is_focused);
        return ws ? ws.output : (Quickshell.screens[0]?.name ?? "");
    }
}
