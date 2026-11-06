import QtQuick
import qs.Common
import qs.Widgets

// Small text button (optional leading glyph) on the tonal material.
Clickable {
    id: root

    property string text: ""
    property string glyph: ""

    implicitWidth: row.implicitWidth + Theme.padControl * 2
    implicitHeight: Theme.control
    radius: Theme.radiusSm
    color: "transparent"

    Surface {
        anchors.fill: parent
        radius: root.radius
        hovered: root.hovered
        pressed: root.pressed
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: Theme.gapInline

        Icon {
            visible: root.glyph !== ""
            glyph: root.glyph
            color: Theme.textMuted
        }

        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
        }
    }
}
