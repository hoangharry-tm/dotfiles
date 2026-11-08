import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

// Pulsing dot and elapsed time while recording; click to stop.
BarChip {
    id: root

    wanted: Recorder.recording
    // Never collapsed: it is a safety/recording indicator.
    onClicked: Recorder.stop()

    Rectangle {
        implicitWidth: Theme.spaceSm
        implicitHeight: Theme.spaceSm
        radius: Theme.radiusFull
        color: Theme.tertiary

        // Shared stepped pulse (Common/Pulse.qml): no per-frame repaints.
        opacity: root.visible ? Pulse.opacity : 1
    }

    Label {
        text: Recorder.elapsedLabel
        font.pixelSize: Theme.textSm
        font.features: { "tnum": 1 }
    }

    onVisibleChanged: visible ? Pulse.hold() : Pulse.release()
    Component.onCompleted: if (visible)
        Pulse.hold()
    Component.onDestruction: if (visible)
        Pulse.release()
}
