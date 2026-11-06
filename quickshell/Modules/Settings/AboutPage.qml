import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets

ColumnLayout {
    id: root

    property var info: ({})
    property string uptime: ""

    spacing: Theme.gapSection

    // Read once when the page opens; nothing runs in the background.
    Process {
        running: true
        command: ["sh", "-c", 'r="$HOME/.config/home-manager"; ' + 'h() { git -C "$1" rev-parse --short HEAD 2>/dev/null; git -C "$1" diff --quiet 2>/dev/null || echo dirty; }; ' + 'echo "config $(h "$r" | paste -sd " ")"; echo "dotfiles $(h "$r/configs" | paste -sd " ")"; ' + 'echo "niri $(niri --version 2>/dev/null)"; echo "qs $(qs --version 2>/dev/null)"']
        stdout: StdioCollector {
            onStreamFinished: {
                const o = {};
                for (const l of text.split("\n")) {
                    const i = l.indexOf(" ");
                    if (i > 0)
                        o[l.slice(0, i)] = l.slice(i + 1).replace(/ dirty$/, " (modified)");
                }
                root.info = o;
            }
        }
    }

    FileView {
        path: "/proc/uptime"
        onLoaded: {
            const s = parseFloat(text());
            const d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60);
            root.uptime = (d ? d + " d " : "") + (h ? h + " h " : "") + m + " min";
        }
    }

    Group {
        title: "System"

        ReadOnlyRow {
            title: "Uptime"
            value: root.uptime
        }

        ReadOnlyRow {
            title: "niri"
            value: root.info.niri ?? "..."
        }

        ReadOnlyRow {
            title: "Quickshell"
            value: root.info.qs ?? "..."
        }
    }

    Group {
        title: "Configuration"

        ReadOnlyRow {
            title: "hh-nix-config"
            value: root.info.config ?? "..."
        }

        ReadOnlyRow {
            title: "dotfiles"
            value: root.info.dotfiles ?? "..."
        }
    }
}
