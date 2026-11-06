import QtQuick
import qs.Common

// A keycap + label, e.g. "↵ open". Used in footers.
Row {
    property string key: ""
    property string text: ""

    spacing: 6

    Rectangle {
        width: Math.max(18, cap.implicitWidth + 10)
        height: 18
        radius: 5
        color: Theme.tile
        border.width: 1
        border.color: Theme.hairline

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
