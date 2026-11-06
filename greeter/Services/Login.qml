pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Greetd

// Login state + greetd conversation. In preview mode (GREETER_PREVIEW=1) it
// only fakes the round trip and never touches greetd, so the UI can be
// checked from a normal session.
Singleton {
    id: root

    readonly property bool preview: Quickshell.env("GREETER_PREVIEW") === "1"
    // Same state dir the Theme singleton reads: the greeter runs with
    // XDG_STATE_HOME=/etc/greetd/state, a preview with the real one.
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/theme"

    property var users: []        // [{ name, full }]
    property var sessions: []     // [{ name, exec }]
    property int userIndex: 0
    property int sessionIndex: 0
    property string message: ""
    property bool failed: false
    property bool busy: false
    property string pending: ""   // password waiting for greetd's prompt

    readonly property var user: users[userIndex] ?? { name: "", full: "" }
    readonly property var session: sessions[sessionIndex] ?? { name: "Session", exec: "" }

    function cycle(prop, count, step) {
        if (count > 1)
            root[prop] = (root[prop] + step + count) % count;
    }

    function fail(text) {
        busy = false;
        failed = true;
        message = text;
        pending = "";
    }

    function submit(password) {
        if (busy || password === "" || !user.name)
            return;
        busy = true;
        failed = false;
        message = "";
        if (preview) {
            previewTimer.restart();
            return;
        }
        pending = password;
        Greetd.createSession(user.name);
    }

    Timer {
        id: previewTimer

        interval: 700
        onTriggered: root.fail("Preview mode: login is disabled")
    }

    Connections {
        target: Greetd
        enabled: !root.preview

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (!responseRequired)
                return;
            if (root.pending === "")
                return Greetd.cancelSession(), root.fail("Authentication needs more than a password");
            Greetd.respond(root.pending);
            root.pending = "";
        }
        function onAuthFailure(message) {
            Greetd.cancelSession();
            root.fail("Wrong password");
        }
        function onReadyToLaunch() {
            // quit=true: quickshell exits 0 and greeter-session ends niri.
            Greetd.launch(root.session.exec.split(" "), [], true);
        }
        function onError(error) {
            root.fail(error);
        }
    }

    // Normal accounts only (uid 1000..59999, real shell). Tab-separated.
    Process {
        running: true
        command: ["sh", "-c", "getent passwd | awk -F: '$3>=1000 && $3<60000 && $7!~/nologin|false/ {print $1\"\\t\"$5}'"]
        stdout: StdioCollector {
            onStreamFinished: root.users = text.trim().split("\n").filter(l => l).map(l => {
                const f = l.split("\t");
                return { name: f[0], full: (f[1] || "").split(",")[0] || f[0] };
            })
        }
    }

    // Wayland sessions; niri first so it is the default.
    Process {
        running: true
        command: ["sh", "-c", "for f in /usr/share/wayland-sessions/*.desktop; do awk -F= '/^Name=/&&!n{n=$2} /^Exec=/&&!e{e=$2} END{print n\"\\t\"e}' \"$f\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const all = text.trim().split("\n").filter(l => l).map(l => {
                    const f = l.split("\t");
                    return { name: f[0], exec: f[1] };
                });
                root.sessions = all.filter(s => /niri/i.test(s.exec)).concat(all.filter(s => !/niri/i.test(s.exec)));
            }
        }
    }
}
