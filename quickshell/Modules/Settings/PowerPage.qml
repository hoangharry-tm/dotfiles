import QtQuick
import qs.Common
import qs.Services

SettingsPage {
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

    function idle(key) {
        return "AC " + after("AC", key) + "  ·  battery " + after("BAT", key);
    }

    SettingsGroup {
        visible: Battery.limitSupported
        title: "Charge limit"
        footnote: Battery.limitWritable ? "Keeps both batteries healthier. Charging resumes 5% below the limit." : "No permission: run scripts/system-setup.sh, then log in again."

        SettingsRow {
            enabled: Battery.limitWritable
            title: "Stop charging at"

            SettingsSegmented {
                segmentWidth: Theme.controlXl
                model: [60, 70, 80, 90, 100].map(n => ({ label: n + "%", value: n }))
                current: Battery.limit
                onPicked: v => Battery.setLimit(v)
            }
        }

        SettingsRow {
            enabled: Battery.limitWritable
            title: "Charge to full once"
            description: "Until unplugged or full, then the limit returns"

            SettingsSwitch {
                checked: Battery.fullOnce
                onToggled: Battery.setFullOnce(!Battery.fullOnce)
            }
        }
    }

    SettingsGroup {
        title: "Energy"

        SettingsRow {
            title: "Low power"
            description: "Power-saver profile, no blur, minimal animation"

            SettingsSegmented {
                segmentWidth: Theme.controlXl + Theme.spaceMd
                model: [
                    { label: "Auto", value: "auto" },
                    { label: "Always", value: "always" },
                    { label: "Never", value: "never" }
                ]
                current: Settings.lowPower
                onPicked: v => Settings.lowPower = v
            }
        }

        SettingsRow {
            title: "Keep awake"
            description: "Media and recording already prevent idle"

            SettingsSwitch {
                checked: KeepAwake.enabled
                onToggled: KeepAwake.enabled = !KeepAwake.enabled
            }
        }
    }

    NixNote {
        title: "Idle"
        file: "services.nix"

        SettingsRow {
            title: "Dim screen"
            value: idle("dim")
        }

        SettingsRow {
            title: "Lock"
            value: idle("lock")
        }

        SettingsRow {
            title: "Turn displays off"
            value: idle("off")
        }

        SettingsRow {
            title: "Suspend"
            value: idle("suspend")
        }
    }
}
