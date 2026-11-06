import QtQuick
import qs.Common
import qs.Widgets

// Wallpaper-safe text: a soft offset shadow under a Label, so it stays
// legible on light or dark images without sampling the wallpaper.
Item {
    id: root

    property alias text: top.text
    property alias font: top.font
    property alias color: top.color
    property alias horizontalAlignment: top.horizontalAlignment

    implicitWidth: top.implicitWidth
    implicitHeight: top.implicitHeight

    Label {
        x: Theme.hairlineWidth
        y: Theme.spaceXs / 2
        width: parent.width
        text: top.text
        font: top.font
        color: Theme.textShadow
        horizontalAlignment: top.horizontalAlignment
    }

    Label {
        id: top

        width: parent.width
    }
}
