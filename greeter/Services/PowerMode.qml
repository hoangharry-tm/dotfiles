pragma Singleton

import QtQuick
import Quickshell

// Greeter stand-in for the shell's Services/PowerMode: Theme.qml (copied from
// the desktop shell) reads PowerMode.tier / lowPower for its motion tokens.
// The greeter has no battery or settings state, so it runs the balanced tier
// with full-length (calm) transitions. Keep these property names in step with
// quickshell/Services/PowerMode.qml.
Singleton {
    readonly property bool lowPower: false
    readonly property int tierLevel: 1
    readonly property string tier: "balanced"
}
