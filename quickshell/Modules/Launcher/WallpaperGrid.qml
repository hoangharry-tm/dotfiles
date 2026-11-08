import QtQuick
import Quickshell.Widgets
import qs.Common
import qs.Widgets

// Tile grid for the wallpaper picker (thumbnails) and the emoji picker
// (glyph tiles). Thumbs decode async at thumbnail size so a large folder
// doesn't stall the shell or balloon memory.
GridView {
    id: root

    property int columns: 4
    property int maxRows: 3
    property real ratio: 0.68 // cell height / width
    property int current: 0

    signal chosen(int index)
    signal hovered(int index)

    // Explicit from the item count: contentHeight would loop through the layout width.
    implicitHeight: Math.min(Math.ceil(count / columns), maxRows) * cellHeight
    cellWidth: Math.floor(width / columns)
    cellHeight: Math.round(cellWidth * ratio)
    clip: true
    currentIndex: current
    boundsBehavior: Flickable.StopAtBounds
    highlightMoveDuration: 0

    delegate: Item {
        id: cell

        required property var modelData
        required property int index

        width: root.cellWidth
        height: root.cellHeight

        ClippingRectangle {
            anchors.fill: parent
            anchors.margins: Theme.spaceXs
            radius: Theme.radiusMd
            color: Theme.tile
            border.width: cell.index === root.current ? Theme.spaceXs / 2 : 0
            border.color: Theme.primary

            Image {
                anchors.fill: parent
                source: cell.modelData.image ? "file://" + cell.modelData.image : ""
                sourceSize.width: 320 // decode size, not layout
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
            }

            Label {
                anchors.centerIn: parent
                visible: !!cell.modelData.emoji
                text: cell.modelData.emoji ?? ""
                font.pixelSize: Theme.textHero
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: Theme.controlSm
                color: Theme.glassSolid
                visible: cell.index === root.current

                Label {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spaceSm
                    anchors.rightMargin: Theme.spaceSm
                    text: cell.modelData.title
                    font.pixelSize: Theme.textXs
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPositionChanged: root.hovered(cell.index)
                onClicked: root.chosen(cell.index)
            }
        }
    }
}
