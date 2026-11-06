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
                color: Theme.primary

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
