import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Common
import qs.Modules.Launcher
import qs.Services

SettingsPage {
    id: root

    // Sources refresh on entering the page, like the launcher's modes.
    Component.onCompleted: {
        Wallpapers.refresh();
        status.running = true;
    }

    // Colour mode lives in ~/.local/state/theme, owned by the `wallpaper`
    // script (modules/theme.nix); the page mirrors it. `wallpaper status`
    // prints "<mode> <resolved>"; only the mode is a setting.
    property string mode: "dark"

    Process {
        id: status

        command: ["wallpaper", "status"]
        stdout: StdioCollector {
            onStreamFinished: root.mode = text.trim().split(" ")[0] || "dark"
        }
    }

    // `wallpaper mode <v>` regenerates the palette (~1 s); the control moves at once.
    Process {
        id: setter
    }

    SettingsGroup {
        title: "Wallpaper"
        footnote: "Light and Dark each keep their own wallpaper; a choice here applies to the mode in use."

        WallpaperGrid {
            Layout.fillWidth: true
            model: Wallpapers.files.map(f => ({ title: f.name, image: f.thumb, path: f.path }))
            columns: 4
            maxRows: 3
            current: -1
            onChosen: i => Wallpapers.apply(model[i].path)
        }
    }

    SettingsGroup {
        title: "Display"

        SettingsRow {
            title: "Mode"
            description: root.mode === "auto" ? "Light by day, dark by night" : ""

            SettingsSegmented {
                segmentWidth: Theme.controlXl + Theme.spaceMd
                model: [
                    { glyph: "light_mode", label: "Light", value: "light" },
                    { glyph: "dark_mode", label: "Dark", value: "dark" },
                    { glyph: "brightness_auto", label: "Auto", value: "auto" }
                ]
                current: root.mode
                onPicked: v => {
                    root.mode = v;
                    setter.command = ["wallpaper", "mode", v];
                    setter.running = true;
                }
            }
        }

        SettingsRow {
            title: "Reduce transparency"
            description: "Solid panels instead of glass"

            SettingsSwitch {
                checked: Settings.reduceTransparency
                onToggled: Settings.reduceTransparency = !Settings.reduceTransparency
            }
        }
    }

    SettingsGroup {
        title: "Motion"

        SettingsRow {
            title: "Animation level"
            description: "Detected: " + PowerMode.detectedTier + (PowerMode.saving ? " (one lower while saving power)" : "")

            SettingsSegmented {
                segmentWidth: Theme.controlXl + Theme.spaceMd
                model: [
                    { label: "Auto", value: "auto" },
                    { label: "Low", value: "low" },
                    { label: "Balanced", value: "balanced" },
                    { label: "High", value: "high" }
                ]
                current: Settings.motionTier
                onPicked: v => Settings.motionTier = v
            }
        }

        SettingsRow {
            title: "Scroll style"
            description: Settings.scrollStyle === "smooth" ? "Eased wheel steps and coasting" : "Qt's own: direct and lightest"

            SettingsSegmented {
                model: [
                    { label: "Native", value: "native" },
                    { label: "Smooth", value: "smooth" }
                ]
                current: Settings.scrollStyle
                onPicked: v => Settings.scrollStyle = v
            }
        }
    }

    UnitText {
        id: schedule

        command: ["sh", "-c", 'cat "${XDG_CONFIG_HOME:-$HOME/.config}/wallpaper/schedule" 2>/dev/null']
    }

    NixNote {
        title: "Wallpaper by time of day"
        file: "wallpaper-schedule.nix"

        SettingsRow {
            title: "Schedule"
            value: schedule.text.trim() ? schedule.text.trim().split("\n").map(l => l.split(" ")[0]).join("  ") : "off"
        }
    }
}
