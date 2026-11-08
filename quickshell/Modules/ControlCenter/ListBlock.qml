import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// One inset-grouped list: a flush Group (its DetailList well is the surface)
// with an optional section heading above it (only where the list really has
// sections) and a quiet centred empty line.
ColumnLayout {
    id: block

    property string heading: ""
    property string emptyText: ""
    property bool empty: false
    property int count: 1             // rows the caller supplies (hides the group at 0)
    default property alias rows: group.content

    Layout.fillWidth: true
    spacing: Theme.spaceSm
    visible: count > 0 || (empty && emptyText !== "")

    Label {
        Layout.leftMargin: group.inset + Theme.padControl
        visible: block.heading !== ""
        text: block.heading
        color: Theme.textMuted
        font.pixelSize: Theme.textXs
    }

    Group {
        id: group

        flush: true
        Layout.fillWidth: true
        // Group's own visibleChildren rule does not follow delegates; the block decides.
        visible: true

        Label {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.rowHeight
            visible: block.empty && block.emptyText !== ""
            text: block.emptyText
            color: Theme.textMuted
            font.pixelSize: Theme.textSm
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
