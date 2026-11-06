pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Night light through wlsunset (wlr-gamma-control, which niri implements).
// Modes: "off", "on" (fixed warm tint), "auto" (warm only between sunset and
// sunrise at the location below). Mode and temperatures persist in
// Services/Settings.qml. No process exists while off.
Singleton {
    id: root

    readonly property int warmTemp: Settings.nightWarmTemp   // K while tinted
    readonly property int dayTemp: Settings.nightDayTemp     // K in daylight (auto only)
    // Location for "auto" sunset/sunrise comes from Services/Location.qml.
    readonly property real latitude: Location.latitude
    readonly property real longitude: Location.longitude

    readonly property string mode: Settings.nightMode
    readonly property bool active: mode !== "off"

    // off -> on -> auto -> off
    function cycle() {
        setMode(mode === "off" ? "on" : mode === "on" ? "auto" : "off");
    }

    function setMode(m) {
        Settings.nightMode = m;
    }

    // wlsunset has no "fixed" option; a 1 K gap pins the tint to warmTemp.
    readonly property var args: mode === "auto" ? ["-t", warmTemp, "-T", dayTemp, "-l", latitude, "-L", longitude] : ["-t", warmTemp, "-T", warmTemp + 1]

    // Process args are read at start only: a mode or temperature change
    // stops wlsunset for a beat, then starts it with the new ones.
    Process {
        command: ["wlsunset"].concat(root.args)
        running: root.active && !rearm.running
    }

    Timer {
        id: rearm

        interval: 200
    }

    onArgsChanged: if (active)
        rearm.restart()
}
