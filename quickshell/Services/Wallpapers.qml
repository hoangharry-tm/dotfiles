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

    // Warm the list (and thumbnail cache) once, so the first open is ready.
    Component.onCompleted: refresh()

    function filter(query) {
        const q = query.trim().toLowerCase();
        return q ? files.filter(f => f.name.toLowerCase().includes(q)) : files;
    }

    function apply(path) {
        Quickshell.execDetached(["wallpaper", "set", path]);
    }

    Process {
        id: scan

        // `wallpaper thumbs` lists the images with cached 320px thumbnails
        // (modules/theme.nix), so the grid never decodes 4K originals.
        command: ["wallpaper", "thumbs", root.dir]
        stdout: StdioCollector {
            onStreamFinished: root.files = text.split("\n").filter(l => l).map(l => {
                    const [path, thumb] = l.split("\t");
                    return {
                        path: path,
                        thumb: thumb || path,
                        name: path.split("/").pop().replace(/\.[^.]+$/, "")
                    };
                })
        }
    }
}
