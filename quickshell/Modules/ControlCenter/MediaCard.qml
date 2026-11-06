import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

// Now playing: artwork, title/artist, previous · play/pause · next.
Section {
    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        ClippingRectangle {
            Layout.preferredWidth: 52
            Layout.preferredHeight: 52
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
                size: Theme.iconLg
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
                font.pixelSize: Theme.textSm
            }
        }

        Repeater {
            model: [
                { glyph: "󰒮", run: () => Media.previous() },
                { glyph: Media.playing ? "󰏤" : "󰐊", run: () => Media.toggle() },
                { glyph: "󰒭", run: () => Media.next() }
            ]

            Clickable {
                required property var modelData

                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: 16
                onClicked: modelData.run()

                Icon {
                    anchors.centerIn: parent
                    glyph: parent.modelData.glyph
                    size: Theme.iconLg - 2
                }
            }
        }
    }
}
