import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Appears only while an app is capturing the mic or screen/camera.
BarChip {
    id: root

    wanted: Privacy.active
    // Never collapsed: it is a safety/recording indicator.

    Icon {
        glyph: Privacy.videoActive ? "󰄀" : "󰍬"
        color: Theme.tertiary

        SequentialAnimation on opacity {
            running: root.visible
            loops: Animation.Infinite
            NumberAnimation { to: 0.45; duration: Theme.animPulse; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1; duration: Theme.animPulse; easing.type: Easing.InOutSine }
        }
    }

    Popover {
        target: root
        shown: root.hovered
        padding: Theme.padControl

        InfoRow {
            visible: Privacy.micActive
            glyph: "󰍬"
            label: "Microphone"
            value: Privacy.micApps.join(", ")
            valueColor: Theme.tertiary
        }

        InfoRow {
            visible: Privacy.videoActive
            glyph: "󰄀"
            label: "Screen / camera"
            value: Privacy.videoApps.join(", ")
            valueColor: Theme.tertiary
        }
    }
}
