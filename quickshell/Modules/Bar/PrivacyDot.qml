import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

// Appears only while an app is capturing the mic or camera. Screen sharing
// has its own chip (ScreencastChip), fed by niri.
BarChip {
    id: root

    wanted: Privacy.active
    // Never collapsed: it is a safety/recording indicator.

    Icon {
        glyph: Privacy.cameraActive ? "videocam" : "mic"
        color: Theme.tertiary

        // Shared stepped pulse (Common/Pulse.qml): no per-frame repaints.
        opacity: root.visible ? Pulse.opacity : 1
    }

    Popover {
        target: root
        shown: root.hovered
        padding: Theme.padControl

        InfoRow {
            visible: Privacy.micActive
            glyph: "mic"
            label: "Microphone"
            value: Privacy.micApps.join(", ")
            valueColor: Theme.tertiary
        }

        InfoRow {
            visible: Privacy.cameraActive
            glyph: "videocam"
            label: "Camera"
            value: Privacy.cameraApps.join(", ")
            valueColor: Theme.tertiary
        }
    }

    onVisibleChanged: visible ? Pulse.hold() : Pulse.release()
    Component.onCompleted: if (visible)
        Pulse.hold()
    Component.onDestruction: if (visible)
        Pulse.release()
}
