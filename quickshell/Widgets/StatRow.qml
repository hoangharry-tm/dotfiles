import QtQuick
import QtQuick.Layouts
import qs.Common

// A metric for cards: name left, value right, history sparkline below.
// Fills the width of the column it sits in.
ColumnLayout {
    id: root

    property string name
    property string value
    property var history: []
    property real maxValue: 1
    property color color: Theme.textMuted

    Layout.fillWidth: true
    spacing: Theme.spaceXs

    RowLayout {
        Layout.fillWidth: true

        Label {
            Layout.fillWidth: true
            text: root.name
            color: Theme.textMuted
        }

        Label {
            text: root.value
            font.features: {
                "tnum": 1
            }
            font.pixelSize: Theme.textSm
        }
    }

    Sparkline {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.control
        values: root.history
        maxValue: root.maxValue
        color: root.color
    }
}
