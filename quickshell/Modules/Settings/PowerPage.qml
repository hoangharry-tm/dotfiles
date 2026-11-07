import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

ColumnLayout {
    spacing: Theme.gapSection

    Component.onCompleted: Battery.refresh()

    // Timings come from the swayidle unit Nix installed, so this is never a stale copy.
    UnitText {
        id: unit

        command: ["systemctl", "--user", "cat", "swayidle.service"]
    }

    function minutes(sec) {
        const m = sec / 60;
        return (m % 1 ? m.toFixed(1) : m) + " min";
    }

    // The unit carries IDLE_AC / IDLE_BAT="dim=S lock=S off=S [suspend=S]".
    function after(env, key) {
        const line = unit.text.match(new RegExp("IDLE_" + env + "=([^\"\\n]*)"));
        const m = line && line[1].match(new RegExp(key + "=(\\d+)"));
        return m ? minutes(Number(m[1])) : "never";
    }

    NixNote {
        title: "Idle"
        file: "services.nix"

        ReadOnlyRow {
            title: "Dim screen"
            value: "AC " + after("AC", "dim") + "  ·  battery " + after("BAT", "dim")
        }

        ReadOnlyRow {
            title: "Lock"
            value: "AC " + after("AC", "lock") + "  ·  battery " + after("BAT", "lock")
        }

        ReadOnlyRow {
            title: "Turn displays off"
            value: "AC " + after("AC", "off") + "  ·  battery " + after("BAT", "off")
        }

        ReadOnlyRow {
            title: "Suspend"
            value: "AC " + after("AC", "suspend") + "  ·  battery " + after("BAT", "suspend")
        }
    }

    Group {
        visible: Battery.limitSupported
        title: "Charge limit"

        SettingRow {
            title: "Stop charging at"
            subtitle: Battery.limitWritable ? "Keeps both batteries healthier. Resumes 5% below" : "No permission: run scripts/system-setup.sh, then log in again"

            Segmented {
                width: Theme.launcherWidth / 2
                enabled: Battery.limitWritable
                model: [60, 70, 80, 90, 100].map(n => ({ label: n + "%", value: n }))
                current: Battery.limit
                onPicked: v => Battery.setLimit(v)
            }
        }

        SettingRow {
            title: "Charge to full once"
            subtitle: "Until unplugged or full, then the limit returns"

            SwitchControl {
                enabled: Battery.limitWritable
                checked: Battery.fullOnce
                onToggled: Battery.setFullOnce(!Battery.fullOnce)
            }
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
