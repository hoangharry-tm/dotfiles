import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Common
import qs.Modules.Launcher
import qs.Services
import qs.Widgets

ColumnLayout {
    id: root

    // Sources refresh on entering the page, like the launcher's modes.
    Component.onCompleted: {
        Wallpapers.refresh();
        status.running = true;
        previews.running = true;
    }

    // Colour mode and style live in ~/.local/state/theme, owned by the
    // `wallpaper` script (modules/theme.nix); the page mirrors them.
    property string mode: "dark"
    property string style: "default"
    property var styles: []

    // Runs `wallpaper <args>` (regenerates the palette, ~1 s) and updates the
    // control immediately; swatches follow once the new palette is built.
    function run(args, apply) {
        apply();
        setter.command = ["wallpaper"].concat(args);
        setter.running = true;
    }

    Process {
        id: status

        command: ["wallpaper", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [m, s] = text.trim().split(" ");
                root.mode = m || "dark";
                root.style = s || "default";
            }
        }
    }

    Process {
        id: previews

        command: ["wallpaper", "previews"]
        stdout: StdioCollector {
            onStreamFinished: root.styles = text.split("\n").filter(l => l).map(l => {
                    const [name, ...colors] = l.split("\t");
                    return { name, colors };
                })
        }
    }

    Process {
        id: setter

        onRunningChanged: if (!running)
            previews.running = true
    }

    Group {
        title: "Wallpaper"

        WallpaperGrid {
            Layout.fillWidth: true
            model: Wallpapers.files.map(f => ({ title: f.name, image: f.thumb, path: f.path }))
            columns: 4
            maxRows: 3
            current: -1
            onChosen: i => Wallpapers.apply(model[i].path)
        }

        ReadOnlyRow {
            title: "Folder"
            value: "~/Pictures/Wallpapers"
        }
    }

    Group {
        title: "Colours"

        SettingRow {
            title: "Mode"
            subtitle: root.mode === "auto" ? "Light by day (sunrise to sunset)" : ""

            Segmented {
                width: Theme.launcherWidth / 2
                model: [
                    { glyph: "󰖨", label: "Light", value: "light" },
                    { glyph: "󰖔", label: "Dark", value: "dark" },
                    { glyph: "󰔛", label: "Auto", value: "auto" }
                ]
                current: root.mode
                onPicked: v => root.run(["mode", v], () => root.mode = v)
            }
        }

        // Style: matugen scheme type. Chips preview primary, secondary and
        // tertiary for the current wallpaper and mode.
        Flow {
            Layout.fillWidth: true
            Layout.margins: Theme.spaceSm
            spacing: Theme.spaceXs

            Repeater {
                model: root.styles

                Clickable {
                    id: chip

                    required property var modelData
                    readonly property bool on: modelData.name === root.style

                    implicitWidth: chipRow.implicitWidth + Theme.padControl * 2
                    implicitHeight: Theme.control
                    radius: Theme.radiusSm
                    color: on ? Theme.primaryWash : hovered ? Theme.hover : "transparent"
                    onClicked: root.run(["scheme", modelData.name], () => root.style = modelData.name)

                    Row {
                        id: chipRow

                        anchors.centerIn: parent
                        spacing: Theme.gapInline

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: -Theme.spaceXs

                            Repeater {
                                model: chip.modelData.colors

                                Rectangle {
                                    required property color modelData

                                    width: Theme.spaceMd
                                    height: width
                                    radius: Theme.radiusFull
                                    color: modelData
                                    border.width: Theme.hairlineWidth
                                    border.color: Theme.hairline
                                }
                            }
                        }

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: chip.modelData.name
                            color: chip.on ? Theme.text : Theme.textMuted
                            font.pixelSize: Theme.textXs
                            font.weight: chip.on ? Font.DemiBold : Font.Normal
                        }
                    }
                }
            }
        }

        ReadOnlyRow {
            title: "Neovim and Alacritty"
            value: "follow the palette"
        }
    }

    Group {
        title: "Motion"

        SettingRow {
            title: "Animation level"
            subtitle: "Detected: " + PowerMode.detectedTier + (PowerMode.saving ? " (one lower while saving power)" : "")

            Segmented {
                width: Theme.launcherWidth / 2
                model: [
                    { glyph: "󰁪", label: "Auto", value: "auto" },
                    { glyph: "󰁹", label: "Low", value: "low" },
                    { glyph: "󰁿", label: "Balanced", value: "balanced" },
                    { glyph: "󰂂", label: "High", value: "high" }
                ]
                current: Settings.motionTier
                onPicked: v => Settings.motionTier = v
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

        ReadOnlyRow {
            title: "Schedule"
            value: schedule.text.trim() ? schedule.text.trim().split("\n").map(l => l.split(" ")[0]).join("  ") : "off"
        }
    }

    spacing: Theme.gapSection
}
