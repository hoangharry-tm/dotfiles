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

    // Tint the card with the (palette-harmonised) album-art accent.
    fillA: Qt.tint(Theme.toneRestA, Qt.alpha(Media.tone, Media.hasTint ? 0.22 : 0))
    fillB: Qt.tint(Theme.toneRestB, Qt.alpha(Media.tone, Media.hasTint ? 0.12 : 0))

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
                glyph: "󰎆"
                size: Theme.iconXl
                visible: Media.art === ""
            }
        }

        Column {
            Layout.fillWidth: true

            Label {
                width: parent.width
                text: Media.title
                font.weight: Font.DemiBold
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
            color: Media.tone
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
            font.weight: Font.DemiBold
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
            font.family: Theme.mono
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: Theme.trackHeight / 2
            radius: Theme.radiusFull
            color: Theme.toneRecessA

            Rectangle {
                width: parent.width * Media.progress
                height: parent.height
                radius: Theme.radiusFull
                color: Media.tone

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.animSlow
                    }
                }
            }
        }

        Label {
            text: Media.formatTime(Media.length)
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
            font.family: Theme.mono
        }
    }

    // Transport
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Theme.spaceXl

        Repeater {
            model: [
                { glyph: "󰒮", main: false, run: () => Media.previous() },
                { glyph: Media.playing ? "󰏤" : "󰐊", main: true, run: () => Media.toggle() },
                { glyph: "󰒭", main: false, run: () => Media.next() }
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
                    variant: "accent"
                    hovered: parent.hovered
                    pressed: parent.pressed
                }

                Icon {
                    anchors.centerIn: parent
                    glyph: parent.modelData.glyph
                    size: Theme.iconLg
                    color: parent.modelData.main ? Theme.onAccent : Theme.text
                }
            }
        }
    }
}
