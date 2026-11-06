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

    // Interactive: stays open while the pointer is on the card.
    Popover {
        id: card

        target: root
        shown: root.hovered
        interactive: true
        cardWidth: Theme.popoverWidth

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spaceMd

            ClippingRectangle {
                Layout.preferredWidth: Theme.controlLg + Theme.space2xl
                Layout.preferredHeight: Theme.controlLg + Theme.space2xl
                radius: Theme.radiusSm
                color: Theme.tile

                Image {
                    anchors.fill: parent
                    source: Media.art
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                    asynchronous: true
                }

                Icon {
                    anchors.centerIn: parent
                    glyph: "󰎆"
                    size: Theme.iconXl
                    color: Theme.textMuted
                    visible: Media.art === ""
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceXs

                Label {
                    Layout.fillWidth: true
                    text: Media.title
                    font.pixelSize: Theme.textLg
                    font.weight: Font.DemiBold
                }

                Label {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: Media.artist
                    color: Theme.textMuted
                }

                Label {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: Media.identity
                    color: Theme.textMuted
                    font.pixelSize: Theme.textXs
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Scrubber {
                Layout.fillWidth: true
                value: Media.progress
                enabled: Media.canSeek && Media.length > 0
                onSeeked: f => Media.seek(f)
            }

            RowLayout {
                Layout.fillWidth: true

                Label {
                    Layout.fillWidth: true
                    text: Media.formatTime(Media.position)
                    color: Theme.textMuted
                    font.family: Theme.mono
                    font.pixelSize: Theme.textXs
                }

                Label {
                    text: Media.formatTime(Media.length)
                    color: Theme.textMuted
                    font.family: Theme.mono
                    font.pixelSize: Theme.textXs
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.spaceMd

            Repeater {
                model: [
                    { glyph: "󰒮", main: false, run: () => Media.previous() },
                    { glyph: Media.playing ? "󰏤" : "󰐊", main: true, run: () => Media.toggle() },
                    { glyph: "󰒭", main: false, run: () => Media.next() }
                ]

                Clickable {
                    required property var modelData

                    Layout.preferredWidth: modelData.main ? Theme.controlLg : Theme.control
                    Layout.preferredHeight: Layout.preferredWidth
                    radius: Theme.radiusFull
                    onClicked: modelData.run()

                    Rectangle {
                        anchors.fill: parent
                        visible: parent.modelData.main
                        radius: parent.radius
                        color: Theme.primary
                        opacity: parent.pressed ? 0.7 : parent.hovered ? 0.88 : 1
                    }

                    Icon {
                        anchors.centerIn: parent
                        glyph: parent.modelData.glyph
                        size: parent.modelData.main ? Theme.iconLg : Theme.icon
                        color: parent.modelData.main ? Theme.primaryText : Theme.text
                    }
                }
            }
        }
    }
}
