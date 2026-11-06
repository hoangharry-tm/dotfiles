import QtQuick
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

// Now playing: note + title with a hairline progress along the bottom.
// Click play/pause; scroll to skip; hover for artwork, artist and time.
Clickable {
    id: root

    visible: Media.active
    implicitWidth: row.implicitWidth + 16
    implicitHeight: 26
    onClicked: Media.toggle()
    onScrolled: d => d > 0 ? Media.previous() : Media.next()

    // Position is only polled while the chip is visible and a track plays.
    Binding {
        target: Media
        property: "tracking"
        value: root.visible
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 6

        Icon {
            glyph: Media.playing ? "󰎈" : "󰏤"
            color: Media.playing ? Theme.primary : Theme.textMuted
        }

        Label {
            width: Math.min(implicitWidth, 180)
            text: Media.title
            color: Theme.textMuted
        }
    }

    Rectangle {
        visible: Media.length > 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        x: 8
        height: 2
        radius: 1
        width: (parent.width - 16) * Media.progress
        color: Qt.alpha(Theme.primary, Media.playing ? 0.8 : 0.35)
    }

    Tooltip {
        target: root
        shown: root.hovered

        Row {
            spacing: 12

            IconImage {
                visible: Media.art !== ""
                implicitSize: 56
                source: Media.art
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3

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
