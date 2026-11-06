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

    function set(v) {
        v = Math.max(0.01, Math.min(1, v));
        value = v;
        setter.command = ["brightnessctl", "--class=backlight", "set", Math.round(v * 100) + "%"];
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
