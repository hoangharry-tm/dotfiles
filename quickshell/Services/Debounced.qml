import QtQuick
import Quickshell
import Quickshell.Io

// Debounced, cancellable one-shot command. run() restarts the timer; when it
// fires any previous job is killed and a fresh Process starts. Each job is its
// own object, so output from a killed job can never be mistaken for the
// current one (no shared stdout state). Never blocks the UI thread.
Scope {
    id: root

    property int delay: 120
    readonly property bool busy: job !== null
    property var job: null
    property var next: null

    // done(output, tag): tag is whatever the caller passed to run().
    signal done(string output, var tag)

    function run(command, tag) {
        next = { cmd: command, tag };
        timer.restart();
    }

    function cancel() {
        timer.stop();
        next = null;
        kill();
    }

    function kill() {
        if (!job)
            return;
        job.running = false;
        job.destroy();
        job = null;
    }

    Timer {
        id: timer

        interval: root.delay
        onTriggered: {
            root.kill();
            if (root.next)
                root.job = proc.createObject(root, root.next);
        }
    }

    Component {
        id: proc

        Process {
            id: p

            required property var cmd
            required property var tag

            command: cmd
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    if (root.job !== p)
                        return; // superseded
                    root.job = null;
                    root.done(text, p.tag);
                    p.destroy();
                }
            }
        }
    }
}
