pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Night light through wlsunset (wlr-gamma-control, which niri implements).
// Modes: "off", "on" (fixed warm tint), "auto" (warm only between sunset and
// sunrise at the location below). Persisted in ~/.local/state/quickshell so a
// shell restart keeps it. No process exists while off.
Singleton {
    id: root

    // --- Settings: change these -------------------------------------------
    readonly property int warmTemp: 3500   // K while tinted
    readonly property int dayTemp: 6500    // K in daylight (auto only)
    // Location for "auto" sunset/sunrise (default: Ho Chi Minh City).
    readonly property real latitude: 10.8
    readonly property real longitude: 106.7
    // ----------------------------------------------------------------------

    property string mode: "off"
    readonly property bool active: mode !== "off"

    // off -> on -> auto -> off
    function cycle() {
        setMode(mode === "off" ? "on" : mode === "on" ? "auto" : "off");
    }

    function setMode(m) {
        mode = m;
        store.setText(m);
    }

    // wlsunset has no "fixed" option; a 1 K gap pins the tint to warmTemp.
    readonly property var args: mode === "auto" ? ["-t", warmTemp, "-T", dayTemp, "-l", latitude, "-L", longitude] : ["-t", warmTemp, "-T", warmTemp + 1]

    Process {
        command: ["wlsunset"].concat(root.args)
        running: root.active
    }

    FileView {
        id: store

        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/quickshell/nightlight"
        blockLoading: true
        printErrors: false // absent until first toggle
        atomicWrites: true
        onLoaded: {
            const m = text().trim();
            if (m === "on" || m === "auto")
                root.mode = m;
        }
    }
}
