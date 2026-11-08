import QtQuick
import qs.Common
import qs.Services

SettingsPage {
    SettingsGroup {
        title: "Desktop"

        SettingsRow {
            title: "Desktop widgets"
            description: "Clock and weather on the wallpaper"

            SettingsSwitch {
                checked: Settings.desktopWidgets
                onToggled: Settings.desktopWidgets = !Settings.desktopWidgets
            }
        }
    }

    SettingsGroup {
        title: "Clock"

        SettingsRow {
            title: "Time format"
            description: "Bar and calendar"

            SettingsSegmented {
                model: [
                    { label: "24-hour", value: true },
                    { label: "12-hour", value: false }
                ]
                current: Settings.clock24h
                onPicked: v => Settings.clock24h = v
            }
        }
    }

    SettingsGroup {
        title: "Network"

        SettingsRow {
            title: "Scan length"
            description: "How long a Wi-Fi or Bluetooth refresh scans"

            SettingsSegmented {
                segmentWidth: Theme.controlXl + Theme.spaceMd
                model: [
                    { label: "1 min", value: 60 },
                    { label: "2 min", value: 120 },
                    { label: "5 min", value: 300 }
                ]
                current: Settings.scanWindow
                onPicked: v => Settings.scanWindow = v
            }
        }
    }

    SettingsGroup {
        title: "Notes"

        SettingsRow {
            title: "Quick-note inbox"
            description: "Where the launcher's + appends"

            SettingsField {
                implicitWidth: Theme.launcherWidth / 2
                text: Settings.notesInbox
                onCommitted: v => Settings.notesInbox = v
            }
        }
    }

    SettingsGroup {
        title: "Media"

        SettingsRow {
            title: "Keep player after pause"
            description: "In the bar and Control Center"

            SettingsSlider {
                from: 0
                to: 30
                step: 1
                current: Settings.mediaGraceMs / 1000
                suffix: " s"
                onPicked: v => Settings.mediaGraceMs = v * 1000
            }
        }

        SettingsRow {
            title: "Desktop audio in recordings"
            description: "Record what the speakers play"

            SettingsSwitch {
                checked: Settings.recDesktopAudio
                onToggled: Settings.recDesktopAudio = !Settings.recDesktopAudio
            }
        }
    }

    // Weekly restic backup: schedule comes from the unit Nix installed.
    UnitText {
        id: backupUnit

        command: ["systemctl", "--user", "cat", "backup.timer"]
    }

    NixNote {
        title: "Backups"
        file: "backup.nix"

        SettingsRow {
            title: "Schedule"
            value: (backupUnit.text.match(/OnCalendar=(.*)/) ?? [0, "not installed"])[1]
        }
    }
}
