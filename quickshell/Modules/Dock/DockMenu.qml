import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

// Right-click menu for one dock item, drawn above it. QML-drawn popup, so
// flat glassSolid + hairline (no niri rule). Dock keeps the dock revealed
// while the pointer is on it (Dock.menuHover).
PopupWindow {
    id: root

    required property Item target
    required property var item

    anchor.item: target
    anchor.edges: Edges.Top
    anchor.gravity: Edges.Top
    anchor.margins.bottom: Theme.spaceSm
    visible: true
    color: "transparent"
    implicitWidth: card.width
    implicitHeight: card.height

    component MenuRow: Clickable {
        id: row

        property string text
        property color tint: Theme.text

        Layout.fillWidth: true
        implicitWidth: label.implicitWidth + Theme.padControl * 2
        implicitHeight: Theme.control
        onClicked: {
            Dock.menuKey = "";
            row.act();
        }

        signal act

        Label {
            id: label

            anchors.left: parent.left
            anchors.leftMargin: Theme.padControl
            anchors.verticalCenter: parent.verticalCenter
            text: row.text
            color: row.tint
        }
    }

    Rectangle {
        id: card

        width: col.implicitWidth + Theme.spaceSm * 2
        height: col.implicitHeight + Theme.spaceSm * 2
        radius: Theme.radiusMd
        color: Theme.glassSolid
        border.width: Theme.hairlineWidth
        border.color: Theme.hairline

        HoverHandler {
            onHoveredChanged: Dock.menuHover = hovered
        }

        ColumnLayout {
            id: col

            anchors.centerIn: parent
            spacing: 0

            MenuRow {
                text: root.item.pinned ? "Unpin from dock" : "Pin to dock"
                onAct: Dock.togglePin(root.item)
            }

            MenuRow {
                visible: !root.item.special
                text: "New window"
                onAct: Dock.newWindow(root.item)
            }

            MenuRow {
                visible: root.item.running
                text: "Close all windows"
                tint: Theme.error
                onAct: Dock.closeAll(root.item)
            }
        }
    }

    Component.onDestruction: Dock.menuHover = false
}
