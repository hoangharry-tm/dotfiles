import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

// Appears only while an app is capturing the mic or screen/camera.
BarChip {
    id: root

    visible: Privacy.active

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

    Tooltip {
        target: root
        shown: root.hovered

        Label {
            visible: Privacy.micActive
            text: "󰍬  Microphone · " + Privacy.micApps.join(", ")
        }

        Label {
            visible: Privacy.videoActive
            text: "󰄀  Screen / camera · " + Privacy.videoApps.join(", ")
        }
    }
}
