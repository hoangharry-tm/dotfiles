pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Audio spectrum from cava (raw ascii, ~30 fps). Runs only while media plays
// AND a visible visualiser holds it (hold/release, like Ambient), so idle cost
// is zero.
Singleton {
    id: root

    property int users: 0
    // Normalised 0..1 bar heights; all zero when stopped.
    property var bars: zeros
    readonly property var zeros: Array(10).fill(0)

    function hold() {
        users++;
    }
    function release() {
        users = Math.max(0, users - 1);
    }

    Process {
        command: ["media-cava"]
        running: root.users > 0 && Media.playing

        stdout: SplitParser {
            // One frame per line: "12;40;..;" (trailing delimiter).
            onRead: line => {
                const v = line.split(";", 10).map(s => (+s || 0) / 100);
                if (v.length)
                    root.bars = v;
            }
        }

        onRunningChanged: if (!running)
            root.bars = root.zeros
    }
}
