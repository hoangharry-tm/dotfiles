import QtQuick
import qs.Common

// A rounded hit area with a soft hover/press wash. Put content inside.
Rectangle {
    id: root

    property alias hovered: mouse.containsMouse
    property alias pressed: mouse.pressed
    property bool active: false          // e.g. its popout is open
    property color activeColor: Theme.hover
    property int cursor: Qt.PointingHandCursor

    signal clicked(var mouse)
    signal rightClicked
    signal middleClicked
    signal scrolled(int delta)
    // Opt-in: a wheel handler on every button swallowed scrolling for any list
    // made of them (calendar agenda, Settings, Control Center rows).
    property bool wheelEnabled: false

    radius: Theme.radiusSm
    color: mouse.pressed ? Theme.pressed : active ? activeColor : mouse.containsMouse ? Theme.hover : "transparent"

    // Press dips the control (spring back on release): the cheapest cue that
    // a click registered. The dip is capped to a few px so wide rows barely move.
    scale: mouse.pressed ? Math.max(Theme.pressScale, 1 - Theme.spaceXs / Math.max(width, height, 1)) : 1

    Behavior on scale {
        SpringAnimation {
            spring: Theme.springStiff
            damping: Theme.springDamp
            epsilon: 0.001
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
            easing.type: Theme.easing
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.cursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: m => {
            if (m.button === Qt.RightButton)
                root.rightClicked();
            else if (m.button === Qt.MiddleButton)
                root.middleClicked();
            else
                root.clicked(m);
        }
        onWheel: w => {
            if (root.wheelEnabled)
                root.scrolled(w.angleDelta.y);
            else
                w.accepted = false; // let the enclosing list scroll
        }
    }
}
