import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

// Appears only while an app is capturing the mic or screen/camera.
Item {
    id: root

    visible: Privacy.active
    implicitWidth: visible ? 26 : 0
    implicitHeight: 26

    Icon {
        anchors.centerIn: parent
        glyph: Privacy.videoActive ? "󰄀" : "󰍬"
        color: Theme.tertiary
        size: 14

        SequentialAnimation on opacity {
            running: root.visible
            loops: Animation.Infinite
            NumberAnimation { to: 0.45; duration: Theme.animPulse; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1; duration: Theme.animPulse; easing.type: Easing.InOutSine }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
    }

    Tooltip {
        target: root
        shown: mouse.containsMouse

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
