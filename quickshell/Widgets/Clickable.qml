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

    radius: Theme.radiusSm
    color: mouse.pressed ? Theme.pressed : (mouse.containsMouse || active) ? (active ? activeColor : Theme.hover) : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
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
        onWheel: w => root.scrolled(w.angleDelta.y)
    }
}
