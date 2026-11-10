import QtQuick
import qs.Common

// A seek bar: track + fill + thumb that appears on hover/drag. Emits
// `seeked(fraction)` on press and while dragging; it shows `value` otherwise.
Item {
    id: root

    property real value: 0               // 0..1

    signal seeked(real fraction)

    readonly property real shown: drag.pressed ? Math.max(0, Math.min(1, drag.mouseX / width)) : value

    implicitHeight: Theme.controlSm      // hit area; the track is thinner

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: Theme.trackHeight
        radius: Theme.trackHeight / 2
        color: Theme.tile

        Rectangle {
            width: Math.max(height, parent.width * root.shown)
            height: parent.height
            radius: parent.radius
            color: Theme.primary
        }
    }

    Rectangle {
        visible: root.enabled && (drag.containsMouse || drag.pressed)
        x: Math.max(0, Math.min(root.width - width, root.width * root.shown - width / 2))
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.thumb
        height: Theme.thumb
        radius: Theme.radiusFull
        color: Theme.text
    }

    MouseArea {
        id: drag

        anchors.fill: parent
        anchors.topMargin: -(Theme.control - root.implicitHeight) / 2     // hit area grows to `control`; visuals unchanged
        anchors.bottomMargin: anchors.topMargin
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: m => root.seeked(Math.max(0, Math.min(1, m.x / width)))
        onPositionChanged: m => {
            if (pressed)
                root.seeked(Math.max(0, Math.min(1, m.x / width)));
        }
    }
}
