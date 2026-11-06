import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

ColumnLayout {
    spacing: Theme.gapSection

    // Timings come from the swayidle unit Nix installed, so this is never a stale copy.
    UnitText {
        id: unit

        command: ["systemctl", "--user", "cat", "swayidle.service"]
    }

    function minutes(sec) {
        const m = sec / 60;
        return (m % 1 ? m.toFixed(1) : m) + " min";
    }

    function after(action) {
        const m = unit.text.match(new RegExp("timeout (\\d+) '?" + action));
        return m ? minutes(Number(m[1])) : "not set";
    }

    NixNote {
        title: "Idle"
        file: "services.nix"

        ReadOnlyRow {
            title: "Dim screen"
            value: after("idle-dim")
        }

        ReadOnlyRow {
            title: "Lock"
            value: after("lock-screen")
        }

        ReadOnlyRow {
            title: "Turn displays off"
            value: after("niri msg action power-off-monitors")
        }
    }

    Group {
        title: "Battery"

        SettingRow {
            title: "Low power"
            subtitle: "Power-saver profile, no blur, minimal animation. Auto = on battery"

            Segmented {
                width: Theme.launcherWidth / 2
                model: [
                    { glyph: "󰁹", label: "Auto", value: "auto" },
                    { glyph: "󰌪", label: "Always", value: "always" },
                    { glyph: "󰂎", label: "Never", value: "never" }
                ]
                current: Settings.lowPower
                onPicked: v => Settings.lowPower = v
            }
        }
    }

    Group {
        title: "Inhibit"

        SettingRow {
            title: "Keep awake"
            subtitle: "Playing media and recording already prevent idle"

            SwitchControl {
                checked: KeepAwake.enabled
                onToggled: KeepAwake.enabled = !KeepAwake.enabled
            }
        }
    }
}
