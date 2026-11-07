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

    readonly property bool dragging: dock.dragKey === key

    // Cosine falloff from the hovered slot out to `reach` neighbours.
    readonly property real mag: {
        const d = (dock.hoverIndex < 0 || dock.dragKey !== "") ? dock.reach + 1 : Math.abs(index - dock.hoverIndex);
        const t = Math.min(1, d / (dock.reach + 1));
        return 1 + dock.magnify * (1 + Math.cos(Math.PI * t)) / 2;
    }

    // Neighbours slide aside while a pinned icon is dragged over them.
    readonly property real shift: {
        const f = dock.dragIndex, t = dock.dragTarget;
        if (f < 0 || dragging)
            return 0;
        if (f < t && index > f && index <= t)
            return -dock.stride;
        if (t < f && index >= t && index < f)
            return dock.stride;
        return 0;
    }

    // Launch / attention hop: only while pending, only on bounce-capable tiers.
    property bool launching: false
    readonly property bool isRunning: item?.running ?? false
    onIsRunningChanged: if (isRunning) launching = false
    readonly property bool hopping: dock.bounce && (launching || (item?.urgent ?? false))

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

        x: (tile.divider ? dock.sepSpace : 0) + tile.shift + drag.offset
        z: tile.dragging ? 1 : 0
        width: dock.slot
        height: dock.slot + dock.dotBand
        transformOrigin: Item.Bottom
        scale: tile.mag

        Behavior on x {
            enabled: !tile.dragging
            NumberAnimation {
                duration: Theme.animFast
                easing.type: Theme.easing
            }
        }

        // Hop: rise on the decelerate curve, fall on the accelerate curve,
        // `hop` px (fits the sheet padding). Stops by itself (see timer).
        transform: Translate {
            id: hop

            property real lift: 0
            y: -lift
        }

        SequentialAnimation {
            running: tile.hopping
            loops: Animation.Infinite
            onRunningChanged: if (!running) hop.lift = 0

            NumberAnimation {
                target: hop
                property: "lift"
                to: Theme.spaceSm
                duration: Theme.anim
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: hop
                property: "lift"
                to: 0
                duration: Theme.anim
                easing.type: Easing.InQuad
            }
            PauseAnimation {
                duration: Theme.animFast
            }
        }

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
            // macOS style: the magnified icon is the hover cue, no wash (press still dips + tints).
            color: pressed ? Theme.pressed : (hovered && !dock.mac) ? Theme.hover : "transparent"
            onClicked: {
                if (tile.item && !tile.item.running && !tile.item.special)
                    tile.launching = true;
                Dock.activate(tile.item);
            }
            onMiddleClicked: {
                tile.launching = !tile.item.special;
                Dock.newWindow(tile.item);
            }
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

            // Built-ins have no app icon: draw them as a quiet tile so they read as apps.
            Rectangle {
                anchors.centerIn: parent
                visible: (tile.item?.icon ?? "") === ""
                width: dock.iconSize
                height: width
                radius: Theme.radiusMd
                color: Theme.tile
                border.width: Theme.hairlineWidth
                border.color: Theme.hairline

                Icon {
                    anchors.centerIn: parent
                    glyph: tile.item?.glyph || "󰖯"
                    size: Math.round(dock.iconSize / 2)
                    color: Theme.text
                }
            }
        }

        // One dot per window (max 3), accent when focused, error when it wants attention.
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            y: dock.slot + (dock.dotBand - Theme.spaceXs) / 2
            spacing: Theme.spaceXs

            Repeater {
                model: Math.min(3, tile.item?.wins.length ?? 0)

                Rectangle {
                    width: Theme.spaceXs
                    height: width
                    radius: Theme.radiusFull
                    color: tile.item?.urgent ? Theme.error : tile.item?.focused ? Theme.primary : Theme.textMuted
                }
            }
        }
    }

    // Drag a pinned icon sideways to reorder; releasing commits.
    DragHandler {
        id: drag

        readonly property real offset: active ? translation.x : 0

        enabled: tile.item?.pinned ?? false
        target: null
        xAxis.enabled: true
        yAxis.enabled: false
        onActiveChanged: {
            if (active) {
                dock.dragKey = tile.key;
                dock.dragIndex = tile.index;
                dock.dragTarget = tile.index;
                return;
            }
            if (dock.dragTarget !== dock.dragIndex)
                Dock.moveTo(tile.key, dock.dragTarget);
            dock.dragKey = "";
            dock.dragIndex = dock.dragTarget = -1;
        }
        onTranslationChanged: {
            if (active)
                dock.dragTarget = Math.max(0, Math.min(dock.pinnedCount - 1, tile.index + Math.round(translation.x / dock.stride)));
        }
    }

    // The hop ends when the app's window shows up (or after a few seconds).
    Timer {
        interval: Theme.hoverOpen * 12
        running: tile.launching
        onTriggered: tile.launching = false
    }

    // Name label above the icon after a short hover (not while a menu is up).
    LazyLoader {
        active: wash.hovered && Dock.menuKey === "" && dock.dragKey === ""

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
