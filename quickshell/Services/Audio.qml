pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Default speaker and microphone (PipeWire), plus device lists for pickers.
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real micVolume: source?.audio?.volume ?? 0
    readonly property bool micMuted: source?.audio?.muted ?? false

    readonly property var sinks: Pipewire.nodes.values.filter(n => n.audio && n.isSink && !n.isStream)
    readonly property var sources: Pipewire.nodes.values.filter(n => n.audio && !n.isSink && !n.isStream && n.type === PwNodeType.AudioSource)

    // Playback streams (one per app) for the per-app mixer.
    readonly property var streams: Pipewire.nodes.values.filter(n => n.audio && n.isStream && n.isSink)
    // Streams are only bound while the mixer is on screen (cheap when closed).
    property bool mixerOpen: false

    readonly property string volumeIcon: muted ? "󰝟" : volume < 0.01 ? "󰕿" : volume < 0.5 ? "󰖀" : "󰕾"
    readonly property string micIcon: micMuted ? "󰍭" : "󰍬"

    function setVolume(value) {
        if (!sink?.audio)
            return;
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    function setMicVolume(value) {
        if (!source?.audio)
            return;
        source.audio.muted = false;
        source.audio.volume = Math.max(0, Math.min(1, value));
    }

    function toggleMute() {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    function toggleMicMute() {
        if (source?.audio)
            source.audio.muted = !source.audio.muted;
    }

    function setSink(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function setSource(node) {
        Pipewire.preferredDefaultAudioSource = node;
    }

    function streamName(node) {
        const p = node.properties;
        return p["application.name"] || p["media.name"] || node.description || node.name || "Unknown";
    }

    function streamIcon(node) {
        const name = node.properties["application.icon-name"] || node.properties["application.process.binary"] || "";
        return name ? Quickshell.iconPath(name, true) : "";
    }

    function nameOf(node) {
        return node?.description || node?.nickname || node?.name || "Unknown";
    }

    // Bind the nodes so their audio properties (volume, mute) stay live.
    PwObjectTracker {
        objects: [root.sink, root.source].concat(root.sinks, root.sources, root.mixerOpen ? root.streams : [])
    }
}
