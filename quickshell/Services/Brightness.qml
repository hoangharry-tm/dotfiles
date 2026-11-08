pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

// Screen backlight, read and written through brightnessctl (pacman: it
// ships the udev rules that let users change the backlight).
Singleton {
    id: root

    property real value: 0          // 0..1
    property bool available: false

    signal changedByUser

    // One source of truth: the device. Every brightnessctl call runs through a
    // single serialized runner and its -m output ("dev,class,cur,pct%,max") is
    // the real level. Slider drags and key presses only queue intent (latest
    // wins; steps are summed), so writes never overlap or finish out of order,
    // and `value` follows the optimistic target only until the device answers.
    property real wanted: -1    // absolute target (0..1), latest wins
    property int pendingSteps: 0 // key presses, in percent
    property bool stepShown: false // show the OSD when the runner finishes
    property int seq: 0         // bumped per request; stale reads are dropped

    function set(v) {
        value = wanted = Math.max(0.01, Math.min(1, v));
        seq++;
        pendingSteps = 0; // an explicit target supersedes queued key steps
        flush();
    }

    function step(delta) {
        pendingSteps += Math.round(delta * 100);
        stepShown = true;
        seq++;
        flush();
    }

    function refresh() {
        if (!runner.running)
            read(["brightnessctl", "-m", "--class=backlight", "info"]);
    }

    function read(cmd) {
        runner.cmd = cmd;
        runner.mark = seq;
        runner.command = cmd;
        runner.running = true;
    }

    function flush() {
        if (runner.running)
            return; // onRunningChanged re-enters when it exits
        if (wanted >= 0) {
            const pct = Math.round(wanted * 100);
            wanted = -1;
            read(["brightnessctl", "-m", "--class=backlight", "--min-value=1%", "set", pct + "%"]);
        } else if (pendingSteps !== 0) {
            const d = pendingSteps;
            pendingSteps = 0;
            read(["brightnessctl", "-m", "--class=backlight", "--min-value=1%", "set", Math.abs(d) + "%" + (d > 0 ? "+" : "-")]);
        }
    }

    Process {
        id: runner

        property var cmd: []
        property int mark: 0

        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(",");
                const c = parseInt(f[2]), m = parseInt(f[4]);
                if (!(m > 0))
                    return;
                root.available = true;
                // Newer intent queued or arrived meanwhile: this answer is
                // stale, keep the optimistic value instead of jumping back.
                if (root.seq !== runner.mark || root.wanted >= 0 || root.pendingSteps !== 0)
                    return;
                root.value = c / m;
                if (root.stepShown) {
                    root.stepShown = false;
                    root.changedByUser();
                }
            }
        }
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
