pragma Singleton

import QtQuick

// One shared slow clock for ambient gradient drift. It only runs while a
// sheet that uses it is open (`hold`/`release`), so idle cost is zero.
Item {
    id: root

    property int users: 0
    // 0..1..0, eased: "on" surfaces slide their gradient axis with it.
    property real phase: 0

    function hold() {
        users++;
    }
    function release() {
        users = Math.max(0, users - 1);
    }

    SequentialAnimation on phase {
        running: root.users > 0
        loops: Animation.Infinite

        NumberAnimation {
            to: 1
            duration: Theme.animAmbient
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            to: 0
            duration: Theme.animAmbient
            easing.type: Easing.InOutSine
        }
    }
}
