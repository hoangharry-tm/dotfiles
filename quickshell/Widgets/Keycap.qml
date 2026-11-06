import QtQuick
import qs.Common

// One keyboard key: a small rounded cap. Single glyphs get a square cap.
Rectangle {
    id: root

    property string text: ""

    implicitWidth: Math.max(implicitHeight, cap.implicitWidth + Theme.spaceSm * 2)
    implicitHeight: Theme.spaceLg + Theme.spaceXs
    radius: Theme.radiusXs
    color: Theme.tile

    Label {
        id: cap

        anchors.centerIn: parent
        text: root.text
        color: Theme.textMuted
        font.pixelSize: Theme.textXs
    }
}
