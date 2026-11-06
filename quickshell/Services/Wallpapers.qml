pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Images in ~/Pictures/Wallpapers, and applying one via the `wallpaper` CLI
// (which regenerates the whole palette with matugen).
Singleton {
    id: root

    readonly property string dir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property var files: [] // [{ path, name }]

    function refresh() {
        scan.running = true;
    }

    function filter(query) {
        const q = query.trim().toLowerCase();
        return q ? files.filter(f => f.name.toLowerCase().includes(q)) : files;
    }

    function apply(path) {
        Quickshell.execDetached(["wallpaper", "set", path]);
    }

    Process {
        id: scan

        command: ["find", root.dir, "-maxdepth", "1", "-type", "f", "-regextype", "posix-extended", "-iregex", ".*\\.(jpe?g|png|webp|avif|bmp)"]
        stdout: StdioCollector {
            onStreamFinished: root.files = text.split("\n").filter(l => l).sort().map(p => ({
                        path: p,
                        name: p.split("/").pop().replace(/\.[^.]+$/, "")
                    }))
        }
    }
}
