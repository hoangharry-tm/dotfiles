import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// Shared frame for expanded lists, the child of the connectivity tile that
// opened it (DESIGN.md "Hierarchy"): an L2 recessed well, radiusMd like the
// tiles above it, holding a header row (title, optional refresh) over one or
// more flush `ListBlock`s (children go into the body). The blocks keep Group's
// inset, so rows, headings and the title all sit on column A.
Surface {
    id: root

    property string title: ""
    property string actionGlyph: ""
    property bool actionActive: false
    property string actionTip: ""
    property string emptyText: ""
    property int count: 0
    default property alias rows: body.data

    signal action

    // Text inset shared by headers and headings: Group inset + row padding.
    readonly property int textInset: Theme.spaceXs + Theme.padControl

    variant: "recessed"
    radius: Theme.radiusMd
    implicitHeight: column.implicitHeight + Theme.spaceXs

    ColumnLayout {
        id: column

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: Theme.spaceXs
        // No layout spacing: an empty body would still add a gap. The header carries its own.
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: root.textInset
            Layout.rightMargin: root.textInset - act.inset // hang: the glyph stays on the content edge
            visible: root.title !== "" || root.actionGlyph !== ""

            Label {
                Layout.fillWidth: true
                text: root.title
                font.weight: Theme.weightEmphasis
            }

            Button {
                id: act

                visible: root.actionGlyph !== ""
                glyph: root.actionGlyph
                busy: root.actionActive
                tip: root.actionTip
                onClicked: root.action()
            }
        }

        ListBlock {
            count: 0
            empty: root.count === 0
            emptyText: root.emptyText
        }

        ColumnLayout {
            id: body

            Layout.fillWidth: true
            spacing: Theme.gapSection
        }
    }
}
