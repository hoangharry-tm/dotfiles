pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// ThinkPad LEDs, driven from the shell (udev makes them group-writable,
// scripts/system-setup.sh "hardware"). Absent or not writable = silent no-op:
// writability is probed (`test -w`) at start and again after a failed write or
// an unlock (the usual point after resume, once udev has re-applied perms).
//   Lid logo dot: blinks 1 Hz while screen recording; solid while there are
//                 unread notifications (not in Do Not Disturb); else off.
//                 Recording wins over unread.
//   Mic-mute LED: on while the PipeWire default source is muted (the kernel
//                 audio-micmute trigger is switched off so it can't disagree).
// The blink timer only runs while recording, so idle cost is zero.
Singleton {
    id: root

    readonly property bool unread: Notifications.history.length > 0 && !Notifications.dnd
    property bool phase: true

    readonly property int dotValue: Recorder.recording ? (phase ? 1 : 0) : unread ? 1 : 0
    readonly property int micValue: Audio.micMuted ? 1 : 0

    // Names the writable LED files: one `sh` per probe, empty on machines
    // without them. `writable` holds the sysfs paths that passed.
    property var writable: []
    readonly property var _paths: ["/sys/class/leds/tpacpi::lid_logo_dot/brightness", "/sys/class/leds/platform::micmute/brightness", "/sys/class/leds/platform::micmute/trigger"]

    function probe() {
        if (!probeProc.running)
            probeProc.running = true;
    }

    Component.onCompleted: probe()

    Process {
        id: probeProc

        command: ["sh", "-c", 'for f in "$@"; do [ -w "$f" ] && echo "$f"; done; exit 0', "sh"].concat(root._paths)
        stdout: StdioCollector {
            onStreamFinished: root.writable = text.split("\n").filter(l => l !== "")
        }
    }

    Connections {
        target: Lock

        function onUnlocked() {
            root.probe();
        }
    }

    component Led: FileView {
        id: led

        property string name
        property int value: 0
        property bool present: false
        readonly property bool canWrite: root.writable.includes(path)

        path: "/sys/class/leds/" + name + "/brightness"
        // sysfs attributes can't be written atomically (temp file + rename
        // is impossible in /sys): every write failed with atomic writes on.
        atomicWrites: false
        printErrors: false
        onLoaded: present = true
        onPresentChanged: push()
        onValueChanged: push()
        onCanWriteChanged: push()
        onSaveFailed: root.probe()
        function push() {
            if (present && canWrite)
                setText(value + "\n");
        }
    }

    Led {
        name: "tpacpi::lid_logo_dot"
        value: root.dotValue
    }

    Led {
        name: "platform::micmute"
        value: root.micValue
        onCanWriteChanged: if (canWrite && trigger.canWrite)
            trigger.setText("none\n")
    }

    FileView {
        id: trigger

        readonly property bool canWrite: root.writable.includes(path)

        path: "/sys/class/leds/platform::micmute/trigger"
        atomicWrites: false
        printErrors: false
    }

    Timer {
        running: Recorder.recording
        interval: 500
        repeat: true
        onTriggered: root.phase = !root.phase
        onRunningChanged: root.phase = true
    }
}
