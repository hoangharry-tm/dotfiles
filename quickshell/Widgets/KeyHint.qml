import QtQuick
import qs.Common

// A keycap + label, e.g. "↵ open". Used in footers.
Row {
    property string key: ""
    property string text: ""

    spacing: Theme.spaceSm

    Rectangle {
        width: Math.max(Theme.spaceLg + Theme.spaceXs, cap.implicitWidth + Theme.spaceSm * 2)
        height: Theme.spaceLg + Theme.spaceXs
        radius: Theme.radiusXs
        color: Theme.tile

        Label {
            id: cap

            anchors.centerIn: parent
            text: parent.parent.key
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }
    }

    Label {
        anchors.verticalCenter: parent.verticalCenter
        text: parent.text
        color: Theme.textMuted
        font.pixelSize: Theme.textXs
    }
}
