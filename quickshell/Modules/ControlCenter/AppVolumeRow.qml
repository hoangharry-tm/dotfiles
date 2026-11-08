import QtQuick
import qs.Services

// One playing app's volume: its mark and name on a LevelRow.
LevelRow {
    id: root

    required property var node

    iconSource: Audio.streamIcon(node)
    label: Audio.streamName(node)
    value: node.audio.volume
    muted: node.audio.muted
    onMoved: v => {
        node.audio.muted = false;
        node.audio.volume = v;
    }
    onMuteToggled: node.audio.muted = !muted
}
