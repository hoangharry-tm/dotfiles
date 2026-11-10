pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// ThinkPad LEDs, driven from the shell (udev makes them group-writable,
// scripts/system-setup.sh "hardware"). Absent or not writable = silent no-op.
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

    component Led: FileView {
        id: led

        property string name
        property int value: 0
        property bool present: false

        path: "/sys/class/leds/" + name + "/brightness"
        // sysfs attributes can't be written atomically (temp file + rename
        // is impossible in /sys): every write failed with atomic writes on.
        atomicWrites: false
        printErrors: false
        onLoaded: present = true
        onPresentChanged: push()
        onValueChanged: push()
        function push() {
            if (present)
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
        onPresentChanged: if (present)
            trigger.setText("none\n")
    }

    FileView {
        id: trigger

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
