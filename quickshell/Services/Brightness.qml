pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

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

    // Brightness keys (via IPC). Relative steps go to brightnessctl, which
    // reads the real level itself; reading sysfs here returned the level from
    // before the previous press (FileView reload lags), so steps jumped around
    // (100 -> 90 -> 95). Presses during a write are summed, never dropped.
    property int pendingSteps: 0 // in percent

    function step(delta) {
        pendingSteps += Math.round(delta * 100);
        flushSteps();
    }

    function flushSteps() {
        if (stepper.running || pendingSteps === 0)
            return;
        const d = pendingSteps;
        pendingSteps = 0;
        stepper.command = ["brightnessctl", "-m", "--class=backlight", "--min-value=1%", "set", Math.abs(d) + "%" + (d > 0 ? "+" : "-")];
        stepper.running = true;
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

    // -m prints "device,class,current,percent%,max": take the new level from
    // brightnessctl itself, then show the OSD.
    Process {
        id: stepper

        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(",");
                const c = parseInt(f[2]), m = parseInt(f[4]);
                if (m > 0) {
                    root.value = c / m;
                    root.available = true;
                    root.changedByUser();
                }
            }
        }
        onRunningChanged: if (!running)
            root.flushSteps()
    }

    Process {
        id: setter

        onRunningChanged: if (!running)
            root.flush()
    }

    Component.onCompleted: refresh()

    // sysfs can't be watched for changes; poll gently, and only while the
    // Control Center (the only live display of brightness) is open.
    Timer {
        interval: 2000
        running: Panels.open === "control"
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
