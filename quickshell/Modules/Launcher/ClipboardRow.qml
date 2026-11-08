import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// One compact clipboard row: type glyph (or colour swatch), one-line preview,
// pin mark (all neutral: selection is the list highlight's accent). The selection wash is the list's highlight, so the row stays flat.
Item {
    id: root

    property var item // transiently another mode's item while the mode flips: guard reads
    readonly property string kind: item?.kind ?? "text"
    property bool current: false

    signal clicked
    signal entered

    implicitHeight: Theme.controlLg

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: root.entered() // not onEntered: scrolling under a still pointer must not steal selection
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.padControl
        anchors.rightMargin: Theme.padControl
        spacing: Theme.gapInline

        Item {
            Layout.preferredWidth: Theme.icon
            Layout.preferredHeight: Theme.icon

            Icon {
                anchors.centerIn: parent
                visible: root.kind !== "color"
                glyph: Clipboard.kinds[root.kind]?.glyph ?? ""
                color: Theme.textMuted
            }

            // Colour entries show the colour itself instead of a glyph.
            Rectangle {
                anchors.centerIn: parent
                visible: root.kind === "color"
                width: Theme.icon
                height: Theme.icon
                radius: Theme.radiusXs
                color: visible ? Clipboard.toColor(root.item?.title ?? "") : "transparent"
                border.width: Theme.hairlineWidth
                border.color: Theme.hairline
            }
        }

        Label {
            Layout.fillWidth: true
            text: root.item?.title ?? ""
            color: !!root.item?.entry?.image ? Theme.textMuted : Theme.text
            // Code/paths read better in mono; also keeps ids/hashes aligned.
            font.family: root.kind === "code" || root.kind === "path" ? Theme.mono : Theme.font
        }

        Icon {
            visible: !!root.item?.entry?.pinned
            glyph: "push_pin"
            filled: true
            size: Theme.iconSm
            color: Theme.textMuted
        }
    }
}
