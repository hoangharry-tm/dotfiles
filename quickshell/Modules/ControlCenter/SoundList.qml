import QtQuick
import QtQuick.Layouts
import qs.Services

// Everything behind the volume slider: output device, per-app volumes,
// input device with its level.
DetailList {
    // Bind the per-app streams only while this is on screen.
    Component.onCompleted: Audio.mixerOpen = true
    Component.onDestruction: Audio.mixerOpen = false

    AudioList {
        output: true
    }

    ListBlock {
        count: Audio.streams.length
        heading: "Apps"

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
        output: false

        LevelRow {
            Layout.fillWidth: true
            visible: Audio.source !== null
            glyph: Audio.micMuted ? "mic_off" : "mic"
            label: "Input level"
            value: Audio.micVolume
            muted: Audio.micMuted
            onMoved: v => Audio.setMicVolume(v)
            onMuteToggled: Audio.toggleMicMute()
        }
    }
}
