pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Screen recording with wf-recorder (wlr-screencopy + VAAPI encode on the
// Intel GPU). Records the focused output to ~/Videos/Recordings/<time>.mp4.
// The elapsed timer only ticks while recording, so idle cost is zero.
Singleton {
    id: root

    readonly property bool desktopAudio: Settings.recDesktopAudio   // capture what the speakers play
    property bool recording: false
    property int elapsed: 0             // seconds
    property string file: ""

    readonly property string dir: Quickshell.env("HOME") + "/Videos/Recordings"
    readonly property string elapsedLabel: {
        const m = Math.floor(elapsed / 60), s = elapsed % 60;
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    function toggle() {
        recording ? stop() : start();
    }

    function start() {
        if (recording || picker.running)
            return;
        // wf-recorder must be told the output when there are several.
        picker.running = true;
    }

    function stop() {
        if (recording)
            rec.signal(2); // SIGINT: wf-recorder finalizes the mp4 on it
    }

    function _begin(output) {
        const t = Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss");
        file = dir + "/" + t + ".mp4";
        const cmd = ["sh", "-c", 'mkdir -p "$1" && shift && exec "$@"', "sh", dir, "wf-recorder", "-o", output, "-f", file, "-c", "h264_vaapi", "-d", "/dev/dri/renderD128"];
        if (desktopAudio && Audio.sink)
            cmd.push("--audio=" + Audio.sink.name + ".monitor");
        rec.command = cmd;
        elapsed = 0;
        rec.running = true;
    }

    Process {
        id: picker

        command: ["niri", "msg", "--json", "focused-output"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root._begin(JSON.parse(text).name);
                } catch (e) {
                    console.warn("Recorder: no focused output");
                }
            }
        }
    }

    Process {
        id: rec

        onRunningChanged: {
            root.recording = running;
            if (!running && root.file !== "")
                notice.running = true;
        }
    }

    Timer {
        running: root.recording
        interval: 1000
        repeat: true
        onTriggered: root.elapsed++
    }

    // notify-send -A waits for the click and prints the action id.
    Process {
        id: notice

        command: ["notify-send", "-a", "Screen recorder", "-i", "media-record", "-A", "open=Open folder", "Recording saved", root.file]
        stdout: StdioCollector {
            onStreamFinished: if (text.trim() === "open")
                Apps.run(["xdg-open", root.dir])
        }
    }
}
