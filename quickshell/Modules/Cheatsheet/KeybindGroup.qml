import QtQuick
import qs.Common
import qs.Widgets

// A titled section of shortcut rows.
Column {
    id: root

    required property var group
    property int rowHeight: Theme.controlSm
    property int headHeight: Theme.controlSm

    Label {
        width: parent.width
        height: root.headHeight
        text: root.group.name
        color: Theme.text
        font.weight: Theme.weightEmphasis
    }

    Repeater {
        model: root.group.rows

        KeybindRow {
            required property var modelData

            width: root.width
            height: root.rowHeight
            row: modelData
        }
    }
}
