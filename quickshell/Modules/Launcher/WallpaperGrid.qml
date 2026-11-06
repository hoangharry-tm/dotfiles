import QtQuick
import Quickshell.Widgets
import qs.Common
import qs.Widgets

// Thumbnail grid for the wallpaper picker. Thumbs decode async at thumbnail
// size so a large folder doesn't stall the shell or balloon memory.
GridView {
    id: root

    readonly property int columns: 4
    property int current: 0

    signal chosen(int index)
    signal hovered(int index)

    // Explicit from the item count: contentHeight would loop through the layout width.
    implicitHeight: Math.min(Math.ceil(count / columns), 3) * cellHeight
    cellWidth: Math.floor(width / columns)
    cellHeight: Math.round(cellWidth * 0.68)
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
            anchors.margins: 4
            radius: Theme.radiusMd
            color: Theme.tile
            border.width: cell.index === root.current ? 2 : 0
            border.color: Theme.primary

            Image {
                anchors.fill: parent
                source: cell.modelData.image ? "file://" + cell.modelData.image : ""
                sourceSize.width: 320
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 22
                color: Qt.alpha(Theme.surface, 0.7)
                visible: cell.index === root.current

                Label {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
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
