pragma Singleton

import QtQuick
import Quickshell

// One shared, stepped "attention" pulse for live indicators (mic/camera dot,
// screencast and recording chips). A per-frame SequentialAnimation repainted
// both bars at 60 fps for as long as the indicator showed (~30% CPU while a
// browser held the mic). This steps once per Theme.animPulse instead (no fade:
// even a short Behavior re-animated both bars ~10 frames per flip), with a
// gentle dim so the step reads as a calm blink. Bind `opacity: Pulse.opacity`.
Singleton {
    id: root

    property int users: 0
    property bool dim: false
    readonly property real opacity: dim ? 0.6 : 1

    function hold() {
        users++;
    }
    function release() {
        users = Math.max(0, users - 1);
        if (users === 0)
            dim = false;
    }

    Timer {
        interval: Theme.animPulse
        repeat: true
        running: root.users > 0
        onTriggered: root.dim = !root.dim
    }
}
