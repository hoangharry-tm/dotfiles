import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

// Now playing: note + title with a hairline progress along the bottom.
// Click play/pause; scroll to skip; hover for artwork, artist and time.
BarChip {
    id: root

    visible: Media.active
    onClicked: Media.toggle()
    onScrolled: d => d > 0 ? Media.previous() : Media.next()

    // Position is only polled while the chip is visible and a track plays.
    Binding {
        target: Media
        property: "tracking"
        value: root.visible
    }

    Icon {
        glyph: Media.playing ? "󰎈" : "󰏤"
        color: Media.playing ? Theme.primary : Theme.textMuted
    }

    Label {
        Layout.maximumWidth: 180
        text: Media.title
        color: Theme.textMuted
    }

    Rectangle {
        parent: root // outside the chip's row layout
        visible: Media.length > 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.spaceXs / 2
        x: Theme.padControl
        height: Theme.trackThin
        radius: Theme.trackThin / 2
        width: (parent.width - Theme.padControl * 2) * Media.progress
        color: Qt.alpha(Theme.primary, Media.playing ? 0.8 : 0.35)
    }

    Tooltip {
        target: root
        shown: root.hovered

        Row {
            spacing: Theme.spaceMd

            IconImage {
                visible: Media.art !== ""
                implicitSize: Theme.iconApp * 2
                source: Media.art
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spaceXs

                Label {
                    width: Math.min(implicitWidth, 240)
                    text: Media.title
                    font.weight: Font.DemiBold
                }

                Label {
                    width: Math.min(implicitWidth, 240)
                    text: Media.artist
                    visible: text !== ""
                    color: Theme.textMuted
                }

                Label {
                    visible: Media.length > 0
                    text: Media.formatTime(Media.position) + " / " + Media.formatTime(Media.length)
                    color: Theme.textMuted
                    font.family: Theme.mono
                    font.pixelSize: Theme.textXs
                }
            }
        }
    }
}
