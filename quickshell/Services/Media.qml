pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// The media player to show: the one playing, else the most recent one.
Singleton {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var player: players.find(p => p.isPlaying) ?? players[0] ?? null
    readonly property bool active: player !== null && player.trackTitle !== ""
    readonly property bool playing: player?.isPlaying ?? false
    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""
    readonly property string art: player?.trackArtUrl ?? ""

    // MPRIS doesn't push position updates; poll once a second, and only while
    // something is showing it (`tracking`) and a track is playing.
    property bool tracking: false
    readonly property real length: player?.lengthSupported ? player.length : 0
    readonly property real position: player?.positionSupported ? player.position : 0
    readonly property real progress: length > 0 ? Math.min(1, position / length) : 0

    Timer {
        interval: 1000
        running: root.tracking && root.playing
        repeat: true
        triggeredOnStart: true
        onTriggered: root.player?.positionChanged()
    }

    function formatTime(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    function toggle() {
        if (player?.canTogglePlaying)
            player.togglePlaying();
    }

    function next() {
        if (player?.canGoNext)
            player.next();
    }

    function previous() {
        if (player?.canGoPrevious)
            player.previous();
    }
}
