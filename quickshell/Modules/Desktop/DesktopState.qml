pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Whether the desktop widgets show; persisted so a restart keeps it.
Singleton {
    id: root

    property bool enabled: true

    function toggle() {
        enabled = !enabled;
        store.setText(enabled ? "on" : "off");
    }

    FileView {
        id: store

        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/quickshell/desktopwidgets"
        blockLoading: true
        printErrors: false
        atomicWrites: true
        onLoaded: root.enabled = text().trim() !== "off"
    }
}
