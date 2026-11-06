import QtQuick
import qs.Common

// A metric for hover cards: name and value on one line, history sparkline below.
Column {
    id: root

    property string name
    property string value
    property var history: []
    property real maxValue: 1
    property color color: Theme.primary

    width: 200
    spacing: 4

    Item {
        width: parent.width
        height: nameLabel.implicitHeight

        Label {
            id: nameLabel

            text: root.name
            color: Theme.textMuted
            font.pixelSize: Theme.textSm
        }

        Label {
            anchors.right: parent.right
            text: root.value
            font.family: Theme.mono
            font.pixelSize: Theme.textSm
        }
    }

    Sparkline {
        width: parent.width
        height: 26
        values: root.history
        maxValue: root.maxValue
        color: root.color
    }
}
