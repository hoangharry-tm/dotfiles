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

    // Collapse (see ResponsiveRow): title shortens at level 2, the title goes
    // at 4 (glyph only); the visualiser lives in the hover card. Never hidden outright.
    wanted: Media.shown
    function titleCap(l) {
        return l < 2 ? 180 : Theme.control * 3;
    }
    widthAt: l => chipWidth(Theme.icon + (l < 4 ? Theme.gapInline + Math.min(title.implicitWidth, titleCap(l)) : 0))
    onClicked: Media.toggle()

    // Position is only polled while the chip is visible and a track plays.
    Binding {
        target: Media
        property: "tracking"
        value: root.visible
    }

    Icon {
        glyph: Media.playing ? "music_note" : "pause"
        color: Media.playing ? Theme.text : Theme.textMuted
    }

    Label {
        id: title

        visible: root.level < 4
        Layout.maximumWidth: root.titleCap(root.level)
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
        color: Media.playing ? Theme.progressOn : Theme.progressOff
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
                    glyph: "music_note"
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
                    font.weight: Theme.weightTitle
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

            // Lives in the hover card, not on the bar: a 20 fps repaint of
            // every bar window (one per monitor) cost ~10% CPU, the card
            // is a single short-lived window.
            Visualizer {
                visible: Media.playing
                color: Theme.textMuted
                Layout.alignment: Qt.AlignVCenter
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
                    font.features: {
                        "tnum": 1
                    }
                    font.pixelSize: Theme.textXs
                }

                Label {
                    text: Media.formatTime(Media.length)
                    color: Theme.textMuted
                    font.features: {
                        "tnum": 1
                    }
                    font.pixelSize: Theme.textXs
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.spaceMd

            Repeater {
                model: [
                    { glyph: "skip_previous", main: false, run: () => Media.previous() },
                    { glyph: Media.playing ? "pause" : "play_arrow", main: true, run: () => Media.toggle() },
                    { glyph: "skip_next", main: false, run: () => Media.next() }
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
                        color: parent.pressed || parent.hovered ? Theme.pressed : Theme.hover
                    }

                    Icon {
                        anchors.centerIn: parent
                        glyph: parent.modelData.glyph
                        size: parent.modelData.main ? Theme.iconLg : Theme.icon
                        color: Theme.text
                    }
                }
            }
        }
    }
}
