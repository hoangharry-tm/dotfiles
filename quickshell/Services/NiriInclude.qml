import QtQuick
import Quickshell
import Quickshell.Io

// A generated niri include in ~/.local/state/theme/<name> (config.kdl pulls it
// in with `include optional=true`, so niri starts without it). `content` is
// the whole file; empty = no override. Written only when it actually changes:
// every write makes niri reload its config, which briefly drops window blur (a
// visible frosted -> clear -> frosted flicker), and shell restarts used to
// rewrite it. Also used for non-niri state files in the same directory
// (Transparency.qml's firefox-solid.css).
Item {
    id: root

    property string name: ""
    property string content: ""

    function write() {
        if (file.ready && file.text() === content)
            return;
        file.setText(content);
    }
    onContentChanged: if (file.ready || file.missing)
        write()

    FileView {
        id: file

        property bool ready: false   // read once: compare before writing
        property bool missing: false // no file yet: first write creates it

        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/theme/" + root.name
        atomicWrites: true
        printErrors: false
        onLoaded: {
            ready = true;
            root.write();
        }
        onLoadFailed: {
            missing = true;
            root.write();
        }
    }
}
