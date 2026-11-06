import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

// Alt+Tab strip: MRU window tiles, wrapping into rows, scrolling past three.
// Holding Alt keeps it open; releasing Alt focuses the selection.
// Thumbnails: not available (niri has no toplevel capture protocol), so
// tiles show the app icon.
PanelWindow {
    id: root

    readonly property int iconBox: Theme.space2xl * 2
    readonly property int tileW: Theme.space2xl * 5   // wide enough for 'Workspace N · HDMI-A-1'
    readonly property int tileH: iconBox + Theme.space2xl * 2 + Theme.spaceMd
    readonly property int maxRows: 3
    readonly property int count: Switcher.items.length
    readonly property int cols: Math.max(1, Math.min(count, Math.floor((screen.width * 0.9 - 2 * Theme.padSheet) / (tileW + Theme.gapStack))))
    readonly property int rows: Math.ceil(count / cols)
    readonly property int visibleRows: Math.min(rows, maxRows)

    function iconFor(w) {
        const id = w.app_id ?? "";
        if (!id)
            return "";
        const entry = DesktopEntries.heuristicLookup(id);
        return Quickshell.iconPath(entry?.icon || id.toLowerCase(), true);
    }

    screen: Quickshell.screens.find(s => s.name === Switcher.screen) ?? Quickshell.screens[0]
    implicitWidth: cols * tileW + (cols - 1) * Theme.gapStack + 2 * Theme.padSheet
    implicitHeight: visibleRows * tileH + (visibleRows - 1) * Theme.gapStack + 2 * Theme.padSheet
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.namespace: "qs-switcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Glass {
        anchors.fill: parent
        radius: Theme.radiusXl   // tile radiusMd + sheet padding 16; matches rules.kdl
    }

    Item {
        id: keys

        focus: true
        Component.onCompleted: forceActiveFocus()
        onActiveFocusChanged: {
            if (activeFocus)
                Switcher.hasFocus = true;
            else if (Switcher.hasFocus)
                Switcher.close();   // focus stolen: cancel rather than strand the grab
        }
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Tab)
                Switcher.step(1);
            else if (event.key === Qt.Key_Backtab)
                Switcher.step(-1);
            else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down)
                Switcher.step(1);
            else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up)
                Switcher.step(-1);
            else if (event.key === Qt.Key_Escape)
                Switcher.close();
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                Switcher.commit();
            else
                return;
            event.accepted = true;
        }
        Keys.onReleased: event => {
            if (event.key === Qt.Key_Alt && !event.isAutoRepeat) {
                Switcher.commit();
                event.accepted = true;
            }
        }
    }

    Flickable {
        id: flick

        anchors.fill: parent
        anchors.margins: Theme.padSheet
        contentWidth: grid.width
        contentHeight: grid.height
        clip: true
        interactive: false
        boundsBehavior: Flickable.StopAtBounds

        // Keep the selected row in view when there are more than maxRows.
        Connections {
            target: Switcher
            function onIndexChanged() {
                const rowTop = Math.floor(Switcher.index / root.cols) * (root.tileH + Theme.gapStack);
                if (rowTop < flick.contentY)
                    flick.contentY = rowTop;
                else if (rowTop + root.tileH > flick.contentY + flick.height)
                    flick.contentY = rowTop + root.tileH - flick.height;
            }
        }

        Grid {
            id: grid

            columns: root.cols
            spacing: Theme.gapStack

            Repeater {
                model: Switcher.items

                Item {
                    id: tile

                    required property var modelData
                    required property int index
                    readonly property bool current: Switcher.index === index
                    readonly property string icon: root.iconFor(modelData)

                    width: root.tileW
                    height: root.tileH

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radiusMd
                        color: tile.current ? Theme.toneHover : "transparent"
                        // Same ring as the bar's active workspace pill.
                        border.width: tile.current ? Theme.hairlineWidth : 0
                        border.color: Theme.primaryRing
                    }

                    Column {
                        anchors.fill: parent
                        anchors.margins: Theme.spaceSm
                        spacing: Theme.spaceXs

                        Item {
                            width: parent.width
                            height: root.iconBox

                            IconImage {
                                anchors.centerIn: parent
                                implicitSize: root.iconBox
                                source: tile.icon
                                visible: tile.icon !== ""
                            }

                            Icon {
                                anchors.centerIn: parent
                                glyph: "󰖯"
                                size: root.iconBox / 2
                                color: Theme.textMuted
                                visible: tile.icon === ""
                            }
                        }

                        Label {
                            width: parent.width
                            text: tile.modelData.title || tile.modelData.app_id || ""
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideMiddle
                            maximumLineCount: 2
                            wrapMode: Text.Wrap
                            font.weight: tile.current ? Font.DemiBold : Font.Normal
                        }

                        Label {
                            width: parent.width
                            text: Switcher.caption(tile.modelData)
                            horizontalAlignment: Text.AlignHCenter
                            color: Theme.textMuted
                            font.pixelSize: Theme.textXs
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Switcher.pick(tile.index)
                    }
                }
            }
        }
    }
}
