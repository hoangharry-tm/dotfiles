import QtQuick
import QtQuick.Layouts
import qs.Common

// Clipboard mode body: compact virtualised list (left) + preview (right).
// Selection is owned by the launcher (`current`), like ResultList.
RowLayout {
    id: root

    property var model: []
    property int current: 0

    signal chosen(int index)
    signal hovered(int index)

    function positionViewAtIndex(i) {
        list.positionViewAtIndex(i, ListView.Contain);
    }

    readonly property int rows: 8
    spacing: Theme.gapSection

    ListView {
        id: list

        Layout.fillWidth: true
        Layout.horizontalStretchFactor: 2 // 2:3 list:preview, without binding to our own width (recursive layout)
        Layout.preferredHeight: root.rows * (Theme.controlLg + spacing) - spacing // fixed, so the preview never jumps
        model: root.model
        clip: true
        spacing: Theme.spaceXs
        currentIndex: root.current
        highlightMoveDuration: Theme.animFast
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: 0 // only visible rows are instantiated

        highlight: Rectangle {
            radius: Theme.radiusLg // sheet radius (28) - sheet inset (12)
            color: Theme.primaryWash // the one accent mark, as in ResultList
        }

        delegate: ClipboardRow {
            required property var modelData
            required property int index

            width: list.width
            item: modelData
            current: index === root.current
            onClicked: root.chosen(index)
            onEntered: root.hovered(index)
        }
    }

    ClipboardPreview {
        Layout.fillWidth: true
        Layout.horizontalStretchFactor: 3
        Layout.fillHeight: true
    }
}
