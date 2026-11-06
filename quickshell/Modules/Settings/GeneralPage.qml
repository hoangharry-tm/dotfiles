import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services

ColumnLayout {
    spacing: Theme.gapSection

    Group {
        title: "Desktop"

        SettingRow {
            title: "Desktop widgets"
            subtitle: "Clock and weather on the wallpaper"

            SwitchControl {
                checked: Settings.desktopWidgets
                onToggled: Settings.desktopWidgets = !Settings.desktopWidgets
            }
        }
    }

    Group {
        title: "Recording"

        SettingRow {
            title: "Capture desktop audio"
            subtitle: "Record what the speakers play with screen recordings"

            SwitchControl {
                checked: Settings.recDesktopAudio
                onToggled: Settings.recDesktopAudio = !Settings.recDesktopAudio
            }
        }
    }

    Group {
        title: "Settings file"

        ReadOnlyRow {
            title: "Location"
            value: "~/.local/state/quickshell/settings.json"
        }

        SettingRow {
            title: "Edit by hand"
            subtitle: "Changes apply as soon as the file is saved"

            ActionButton {
                glyph: "󰏫"
                text: "Open"
                onClicked: {
                    Panels.close();
                    Quickshell.execDetached(["alacritty", "-e", "nvim", Settings.dir + "/settings.json"]);
                }
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

        ReadOnlyRow {
            title: "Schedule"
            value: (backupUnit.text.match(/OnCalendar=(.*)/) ?? [0, "not installed"])[1]
        }
    }
}
