import QtQuick
import Quickshell.Io

// Text of a command, run once when `active` turns on (no polling). Used to
// show what Nix actually installed (systemd unit files) instead of a copy.
Item {
    id: root

    property var command: []
    property bool active: true
    property string text: ""

    visible: false

    Process {
        command: root.command
        running: root.active
        stdout: StdioCollector {
            onStreamFinished: root.text = text
        }
    }
}
