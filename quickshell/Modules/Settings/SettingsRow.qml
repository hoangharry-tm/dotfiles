import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// One row: title (textMd) and an optional one-line description (textXs
// muted) on the left, ONE control on the right (a Switch, Segmented, Button,
// field, or a plain muted `value`). Padding is `padControl` to column A and
// to the trailing item; the Group around it supplies the inset. A disabled
// row dims as a whole.
Item {
    id: root

    property string title: ""
    property string description: ""
    property string value: ""
    property bool present: true
    default property alias control: slot.data

    Layout.fillWidth: true
    visible: present
    implicitHeight: description ? Theme.rowHeightTall : Theme.rowHeight
    // No dedicated token yet: two stack steps of fade (see report).
    opacity: enabled ? 1 : Theme.disabledOpacity

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.padControl
        anchors.rightMargin: Theme.padControl
        spacing: Theme.gapInline

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Label {
                Layout.fillWidth: true
                text: root.title
            }

            Label {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.description
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }
        }

        Label {
            visible: root.value !== ""
            Layout.maximumWidth: root.width / 2
            text: root.value
            color: Theme.textMuted
            horizontalAlignment: Text.AlignRight
            font.features: {
                "tnum": 1
            }
        }

        Row {
            id: slot

            spacing: Theme.gapInline
        }
    }
}
