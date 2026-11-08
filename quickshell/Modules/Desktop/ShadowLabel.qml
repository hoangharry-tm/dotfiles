import QtQuick
import qs.Common
import qs.Widgets

// Wallpaper-safe text: a soft offset shadow under a Label, so it stays
// legible on light or dark images without sampling the wallpaper.
Item {
    id: root

    property alias text: face.text
    property alias font: face.font
    property alias color: face.color  // defaults to onWallpaper
    property alias horizontalAlignment: face.horizontalAlignment
    property color shadowColor: Theme.wallpaperShadow

    implicitWidth: face.implicitWidth
    implicitHeight: face.implicitHeight

    Label {
        x: Theme.hairlineWidth
        y: Theme.spaceXs / 2
        width: parent.width
        text: face.text
        font: face.font
        color: root.shadowColor
        horizontalAlignment: face.horizontalAlignment
    }

    Label {
        id: face

        width: parent.width
        color: Theme.onWallpaper
    }
}
