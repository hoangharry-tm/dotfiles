import QtQuick
import qs.Common

// Neutral kind pill (e.g. "Image", "PDF"): small caps-free label on the "on"
// fill. Shared by the clipboard and quick-look previews.
Surface {
    id: root

    property alias text: label.text

    implicitWidth: label.implicitWidth + Theme.padControl * 2
    implicitHeight: Theme.controlSm
    radius: Theme.radiusFull
    variant: "on"

    Label {
        id: label

        anchors.centerIn: parent
        color: Theme.textMuted
        font.pixelSize: Theme.textXs
        font.weight: Theme.weightEmphasis
    }
}
