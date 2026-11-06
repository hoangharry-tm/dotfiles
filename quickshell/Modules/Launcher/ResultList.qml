import QtQuick
import qs.Common
import qs.Widgets

// Vertical results (apps, calculator, commands). Selection is owned by the
// launcher (`current`) so hover and keyboard share one source of truth.
ListView {
    id: root

    property int current: 0

    signal chosen(int index)
    signal hovered(int index)

    implicitHeight: Math.min(contentHeight, 7 * (Theme.resultHeight + spacing))
    clip: true
    spacing: Theme.spaceXs
    currentIndex: current
    highlightMoveDuration: Theme.animFast
    boundsBehavior: Flickable.StopAtBounds

    highlight: Rectangle {
        radius: Theme.radiusLg // sheet radius (28) - sheet inset (12)
        color: Theme.hover
    }

    delegate: ResultRow {
        required property var modelData
        required property int index

        width: root.width
        title: modelData.title
        subtitle: modelData.subtitle ?? ""
        iconName: modelData.icon ?? ""
        glyph: modelData.glyph ?? ""
        current: index === root.current
        onClicked: root.chosen(index)
        onEntered: root.hovered(index)
    }
}
