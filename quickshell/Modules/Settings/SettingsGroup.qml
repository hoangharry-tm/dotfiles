import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// A section: a muted heading `spaceSm` above one Widgets/Group of rows, an
// optional muted footnote below (the only place for a note), and an `empty`
// line shown in the group when it has no rows. Heading and footnote start on
// column A, the same x as the row labels (group inset + row padding).
ColumnLayout {
    id: root

    property string title: ""
    property string footnote: ""
    property string empty: ""
    default property alias rows: group.content
    readonly property int columnA: Theme.columnA

    Layout.fillWidth: true
    spacing: Theme.spaceSm

    Label {
        visible: root.title !== ""
        Layout.leftMargin: root.columnA
        text: root.title
        color: Theme.textMuted
        font.pixelSize: Theme.textXs
        font.weight: Theme.weightEmphasis
    }

    Group {
        id: group

        Layout.fillWidth: true

        Label {
            visible: root.empty !== ""
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.rowHeight
            horizontalAlignment: Text.AlignHCenter
            text: root.empty
            color: Theme.textMuted
        }
    }

    Label {
        visible: root.footnote !== ""
        Layout.fillWidth: true
        Layout.leftMargin: root.columnA
        Layout.rightMargin: root.columnA
        text: root.footnote
        color: Theme.textMuted
        font.pixelSize: Theme.textXs
        wrapMode: Text.WordWrap
        elide: Text.ElideNone
    }
}
