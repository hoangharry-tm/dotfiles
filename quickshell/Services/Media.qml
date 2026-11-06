pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.Common

// The media player to show: the one playing, else the most recent one.
Singleton {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var player: players.find(p => p.isPlaying) ?? players[0] ?? null
    readonly property bool active: player !== null && player.trackTitle !== ""
    readonly property bool playing: player?.isPlaying ?? false

    // Media UI shows while playing, and for `graceMs` after a pause so a brief
    // pause doesn't blink it away (single-shot timer, no polling).
    readonly property int graceMs: 10000
    readonly property bool shown: active && (playing || grace.running)
    Timer {
        id: grace

        interval: root.graceMs
    }
    onPlayingChanged: if (!playing)
        grace.restart()
    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""
    readonly property string art: player?.trackArtUrl ?? ""
    readonly property string album: player?.trackAlbum ?? ""

    // Album-art accent: dominant colour (media-accent, cached per cover),
    // re-toned to the palette's own saturation/lightness so only the hue is
    // borrowed from the art and it can't clash with matugen.
    property color artColor: "transparent"
    readonly property bool hasTint: playing && artColor.a > 0
    readonly property color accent: Qt.hsla(artColor.hslHue >= 0 ? artColor.hslHue : Theme.primary.hslHue, Math.min(Theme.primary.hslSaturation, 0.75), Theme.primary.hslLightness, 1)

    // What tinted widgets use: the art accent while playing, else the palette's.
    property color tone: hasTint ? accent : Theme.primary
    Behavior on tone {
        ColorAnimation {
            duration: Theme.animSlow
        }
    }

    property string accentFor: ""
    function refreshAccent() {
        if (!tracking || art === "" || art === accentFor)
            return;
        accentFor = art;
        artColor = "transparent";
        accentProc.running = false;
        accentProc.running = true;
    }
    onArtChanged: refreshAccent()
    onTrackingChanged: refreshAccent()

    // Pure hue sources (greys) carry no hue: fall back to no tint.
    Process {
        id: accentProc

        command: ["media-accent", root.art]
        stdout: StdioCollector {
            onStreamFinished: {
                const c = Qt.color(text.trim() || "transparent");
                root.artColor = c.hslSaturation < 0.08 ? "transparent" : c;
            }
        }
    }

    // MPRIS doesn't push position updates; poll once a second, and only while
    // something is showing it (`tracking`) and a track is playing.
    property bool tracking: false
    readonly property real length: (player?.lengthSupported && player.length) || 0
    readonly property real position: (player?.positionSupported && player.position) || 0 // undefined while a player is (re)appearing
    readonly property real progress: length > 0 ? Math.min(1, position / length) : 0

    Timer {
        interval: Lyrics.users > 0 ? 400 : 1000 // synced lyrics need finer steps
        running: root.tracking && root.playing
        repeat: true
        triggeredOnStart: true
        onTriggered: root.player?.positionChanged()
    }

    readonly property bool canSeek: player?.canSeek ?? false
    readonly property string identity: player?.identity ?? ""

    // fraction 0..1 of the track
    function seek(fraction) {
        if (canSeek && length > 0) {
            player.position = fraction * length;
            player.positionChanged();
        }
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
