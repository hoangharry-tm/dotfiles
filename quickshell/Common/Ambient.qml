pragma Singleton

import QtQuick
import qs.Services

// One shared slow clock for ambient gradient drift. It only runs while a
// sheet that uses it is open (`hold`/`release`), so idle cost is zero.
Item {
    id: root

    property int users: 0
    // 0..1..0, eased: "on" surfaces slide their gradient axis with it.

    function hold() {
        users++;
    }
    function release() {
        users = Math.max(0, users - 1);
    }

    // Stepped at 10 Hz instead of animated per frame: an Animation repaints
    // every Surface at 60 fps (~40% CPU with the Control Center open), while
    // a 9 s drift changes too little per 100 ms for the steps to be visible.
    property real t: 0
    readonly property real phase: 0.5 - 0.5 * Math.cos(t * Math.PI / Theme.animAmbient)

    Timer {
        interval: 100
        repeat: true
        running: root.users > 0 && !PowerMode.lowPower && Theme.motionAmbient // static gradient saves repaints
        onTriggered: root.t = (root.t + interval) % (2 * Theme.animAmbient)
    }
}
