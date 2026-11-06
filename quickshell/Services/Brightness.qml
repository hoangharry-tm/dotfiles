pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Screen backlight. Read from sysfs; written with brightnessctl (pacman: it
// ships the udev rules that let users change the backlight).
Singleton {
    id: root

    readonly property string device: "/sys/class/backlight/intel_backlight"
    property real value: 0          // 0..1
    property bool available: false

    signal changedByUser

    // Writes are coalesced: one brightnessctl at a time, and when it exits
    // the latest requested value is written (intermediate drag values drop).
    property real wanted: -1

    function set(v) {
        value = wanted = Math.max(0.01, Math.min(1, v));
        flush();
    }

    function flush() {
        if (setter.running || wanted < 0)
            return;
        setter.command = ["brightnessctl", "--class=backlight", "set", Math.round(wanted * 100) + "%"];
        wanted = -1;
        setter.running = true;
    }

    // Used by the brightness keys (via IPC) so the OSD shows.
    function step(delta) {
        set(value + delta);
        changedByUser();
    }

    function refresh() {
        current.reload();
        max.reload();
        if (setter.running || wanted >= 0)
            return; // our own write is in flight; sysfs would read stale
        const c = parseInt(current.text()), m = parseInt(max.text());
        if (m > 0) {
            value = c / m;
            available = true;
        }
    }

    FileView {
        id: current

        path: root.device + "/brightness"
        blockLoading: true
    }

    FileView {
        id: max

        path: root.device + "/max_brightness"
        blockLoading: true
    }

    Process {
        id: setter

        onRunningChanged: if (!running)
            root.flush()
    }

    // sysfs can't be watched for changes; poll gently.
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
