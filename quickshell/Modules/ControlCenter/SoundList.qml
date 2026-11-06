import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Everything behind the volume slider: output device, per-app volumes,
// input device with its level.
ColumnLayout {
    spacing: Theme.gapStack

    // Bind the per-app streams only while this is on screen.
    Component.onCompleted: Audio.mixerOpen = true
    Component.onDestruction: Audio.mixerOpen = false

    AudioList {
        Layout.fillWidth: true
        output: true
    }

    Section {
        Layout.fillWidth: true
        visible: Audio.streams.length > 0
        pad: Theme.spaceSm
        recessed: true

        Label {
            Layout.leftMargin: Theme.spaceMd
            text: "Applications"
            font.weight: Font.DemiBold
        }

        Repeater {
            model: Audio.streams

            AppVolumeRow {
                required property var modelData

                Layout.fillWidth: true
                node: modelData
            }
        }
    }

    AudioList {
        Layout.fillWidth: true
        output: false

        Slider {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spaceXs
            visible: Audio.source !== null
            value: Audio.micVolume
            glyph: Audio.micIcon
            dimmed: Audio.micMuted
            onMoved: v => Audio.setMicVolume(v)
            onIconClicked: Audio.toggleMicMute()
        }
    }
}
