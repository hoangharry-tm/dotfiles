import QtQuick
import Quickshell
import qs.Common

// Hover details for a bar item: a small glass card below it.
// Usage: Tooltip { target: someItem; shown: someItem.hovered; content: ... }
PopupWindow {
    id: root

    required property Item target
    property bool shown: false
    default property alias content: column.data

    anchor.item: target
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 10
    visible: shown && delay.done
    color: "transparent"
    implicitWidth: card.width
    implicitHeight: card.height

    // Avoid flicker when the pointer just passes over.
    Timer {
        id: delay

        property bool done: false

        interval: 350
        running: root.shown
        onTriggered: done = true
        onRunningChanged: if (!running && !root.shown)
            done = false
    }

    Rectangle {
        id: card

        width: column.implicitWidth + Theme.pad * 2
        height: column.implicitHeight + 20
        radius: Theme.radiusMd
        color: Theme.glassSolid
        border.width: 1
        border.color: Theme.hairline

        Column {
            id: column

            anchors.centerIn: parent
            spacing: 4
        }
    }
}
