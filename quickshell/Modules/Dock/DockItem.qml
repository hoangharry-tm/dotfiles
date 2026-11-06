import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

// One app slot: icon, running dot (accent when focused), hover wash.
// Magnification lives here, on the icon only; the glass sheet never scales.
Item {
    id: tile

    required property var dock     // DockBar: sizes, hoverIndex, items
    required property string key
    required property int index

    readonly property var item: dock.itemsByKey[key] ?? null
    readonly property bool divider: dock.pinnedCount > 0 && index === dock.pinnedCount

    // Falls off with distance from the hovered slot (1 -> 0.5 -> 0).
    readonly property real mag: {
        const d = dock.hoverIndex < 0 ? 2 : Math.abs(index - dock.hoverIndex);
        return 1 + dock.magnify * Math.max(0, 1 - d / 2);
    }

    width: body.width + (divider ? dock.sepSpace : 0)
    height: body.height

    // Thin rule between pinned and running-only apps.
    Rectangle {
        visible: tile.divider
        anchors.left: parent.left
        anchors.leftMargin: dock.sepSpace / 2
        y: (dock.slot - height) / 2
        width: Theme.hairlineWidth
        height: dock.iconSize
        color: Theme.hairline
    }

    Item {
        id: body

        x: tile.divider ? dock.sepSpace : 0
        width: dock.slot
        height: dock.slot + dock.dotBand
        transformOrigin: Item.Bottom
        scale: tile.mag

        Behavior on scale {
            SpringAnimation {
                spring: Theme.springStiff
                damping: Theme.springDamp
                epsilon: 0.001
            }
        }

        Clickable {
            id: wash

            width: dock.slot
            height: dock.slot
            radius: Theme.radiusSm
            onClicked: Dock.activate(tile.item)
            onMiddleClicked: Dock.newWindow(tile.item)
            onRightClicked: Dock.menuKey = tile.key
            onHoveredChanged: {
                if (hovered)
                    dock.hoverIndex = tile.index;
                else if (dock.hoverIndex === tile.index)
                    dock.hoverIndex = -1;
            }

            IconImage {
                anchors.centerIn: parent
                implicitSize: dock.iconSize
                source: tile.item?.icon ?? ""
                visible: source !== ""
            }

            Icon {
                anchors.centerIn: parent
                visible: (tile.item?.icon ?? "") === ""
                glyph: tile.item?.glyph || "󰖯"
                size: Math.round(dock.iconSize * 0.6)
                color: Theme.textMuted
            }
        }

        Rectangle {
            visible: tile.item?.running ?? false
            anchors.horizontalCenter: parent.horizontalCenter
            y: dock.slot + (dock.dotBand - height) / 2
            width: Theme.spaceXs
            height: width
            radius: Theme.radiusFull
            color: tile.item?.focused ? Theme.primary : Theme.textMuted
        }
    }

    // Name label above the icon after a short hover (not while a menu is up).
    LazyLoader {
        active: wash.hovered && Dock.menuKey === ""

        Tooltip {
            target: body
            shown: true
            anchor.edges: Edges.Top
            anchor.gravity: Edges.Top
            anchor.margins.top: 0
            anchor.margins.bottom: Theme.spaceSm

            Label {
                text: tile.item?.name ?? ""
            }
        }
    }

    LazyLoader {
        active: Dock.menuKey === tile.key && tile.item !== null

        DockMenu {
            target: body
            item: tile.item
            anchor.margins.bottom: Theme.spaceSm + Theme.spaceMd
        }
    }
}
