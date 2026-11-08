import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

// Now playing: artwork, title/artist, transport controls and progress.
Section {
    id: root

    // Position polling runs only while this card is on screen.
    property bool live: false

    // Lyrics are fetched and cava runs only while the card is on screen.
    onLiveChanged: live ? Lyrics.hold() : Lyrics.release()
    Component.onCompleted: if (live)
        Lyrics.hold()
    Component.onDestruction: if (live)
        Lyrics.release()

    Binding {
        target: Media
        property: "tracking"
        value: root.live
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spaceMd

        ClippingRectangle {
            Layout.preferredWidth: Theme.tileHeight
            Layout.preferredHeight: Theme.tileHeight
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
                visible: Media.art === ""
            }
        }

        Column {
            Layout.fillWidth: true

            Label {
                width: parent.width
                text: Media.title
                font.weight: Theme.weightEmphasis
            }

            Label {
                width: parent.width
                text: Media.artist || Media.player?.identity || ""
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }
        }

        Visualizer {
            visible: Media.playing && root.live
            implicitHeight: Theme.controlLg
            barGap: Theme.spaceXs
            color: Theme.textMuted
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // Lyrics: current line, next dimmed. Hidden when the track has none.
    Column {
        Layout.fillWidth: true
        visible: Lyrics.found
        spacing: Theme.spaceXs

        Label {
            width: parent.width
            text: Lyrics.current || "♪"
            font.weight: Theme.weightEmphasis
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            width: parent.width
            text: Lyrics.next
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // Progress
    RowLayout {
        Layout.fillWidth: true
        visible: Media.length > 0
        spacing: Theme.gapInline

        Label {
            text: Media.formatTime(Media.position)
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
            font.features: {
                "tnum": 1
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: Theme.trackHeight / 2
            radius: Theme.radiusFull
            color: Theme.fillRecess

            Rectangle {
                width: parent.width * Media.progress
                height: parent.height
                radius: Theme.radiusFull
                color: Theme.text

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.animSlow
                        easing.type: Theme.easing
                    }
                }
            }
        }

        Label {
            text: Media.formatTime(Media.length)
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
            font.features: {
                "tnum": 1
            }
        }
    }

    // Transport
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Theme.spaceXl

        Repeater {
            model: [
                { glyph: "skip_previous", main: false, run: () => Media.previous() },
                { glyph: Media.playing ? "pause" : "play_arrow", main: true, run: () => Media.toggle() },
                { glyph: "skip_next", main: false, run: () => Media.next() }
            ]

            Clickable {
                required property var modelData

                Layout.preferredWidth: Theme.controlLg
                Layout.preferredHeight: Theme.controlLg
                radius: Theme.radiusFull
                color: modelData.main ? "transparent" : pressed ? Theme.pressed : hovered ? Theme.hover : "transparent"
                onClicked: modelData.run()

                Surface {
                    anchors.fill: parent
                    visible: parent.modelData.main
                    radius: parent.radius
                    variant: "solid"
                    hovered: parent.hovered
                    pressed: parent.pressed
                }

                Icon {
                    anchors.centerIn: parent
                    glyph: parent.modelData.glyph
                    size: Theme.iconLg
                    color: parent.modelData.main ? Theme.onSolid : Theme.text
                }
            }
        }
    }
}
