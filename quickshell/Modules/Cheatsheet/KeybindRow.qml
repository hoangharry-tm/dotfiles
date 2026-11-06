import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// One shortcut: label on the left, one or more key combos on the right.
RowLayout {
    id: root

    required property var row

    spacing: Theme.spaceXs

    Label {
        Layout.fillWidth: true
        Layout.rightMargin: Theme.gapInline
        text: root.row.label
        color: Theme.textMuted
    }

    Repeater {
        model: root.row.tokens

        // "/" separates alternatives; everything else is a key.
        Loader {
            id: tok

            required property string modelData

            sourceComponent: modelData === "/" ? sep : cap

            Component {
                id: cap

                Keycap {
                    text: tok.modelData
                }
            }

            Component {
                id: sep

                Label {
                    text: "/"
                    color: Theme.textMuted
                }
            }
        }
    }
}
