import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services

ColumnLayout {
    id: page

    // Same builder the dock uses, so names/icons/running state match.
    readonly property var apps: Dock.build(Niri.windows, Niri.mru, Settings.dockPinned)
    readonly property var pinned: apps.filter(a => a.pinned)
    readonly property var running: apps.filter(a => !a.pinned)

    spacing: Theme.gapSection

    Group {
        title: "Dock"

        SettingRow {
            title: "Show dock"
            subtitle: "App launcher and switcher at the bottom edge"

            SwitchControl {
                checked: Settings.dockEnabled
                onToggled: Settings.dockEnabled = !Settings.dockEnabled
            }
        }

        SettingRow {
            title: "Auto-hide"
            subtitle: "Reveal when the pointer touches the bottom edge"

            SwitchControl {
                checked: Settings.dockAutoHide
                onToggled: Settings.dockAutoHide = !Settings.dockAutoHide
            }
        }

        SettingRow {
            title: "Style"
            subtitle: "macOS: magnifying wave, launch hop, drag to reorder. Minimal: quiet lift"

            Segmented {
                width: Theme.launcherWidth / 3
                model: [
                    { label: "macOS", value: "macos" },
                    { label: "Minimal", value: "minimal" }
                ]
                current: Settings.dockStyle
                onPicked: v => Settings.dockStyle = v
            }
        }

        SettingRow {
            title: "Icon size"

            SettingSlider {
                from: 32
                to: 64
                step: 4
                current: Settings.dockIconSize
                suffix: " px"
                onPicked: v => Settings.dockIconSize = v
            }
        }
    }

    Group {
        title: "Pinned apps"

        Repeater {
            model: page.pinned

            SettingRow {
                id: row

                required property var modelData
                required property int index

                title: modelData.name

                ActionButton {
                    glyph: "󰁝"
                    visible: row.index > 0
                    onClicked: Dock.movePin(row.modelData.key, -1)
                }

                ActionButton {
                    glyph: "󰁅"
                    visible: row.index < page.pinned.length - 1
                    onClicked: Dock.movePin(row.modelData.key, 1)
                }

                ActionButton {
                    glyph: "󰆴"
                    text: "Unpin"
                    onClicked: Dock.togglePin(row.modelData)
                }
            }
        }

        ReadOnlyRow {
            visible: page.pinned.length === 0
            title: "Nothing pinned"
            value: "pin a running app below"
        }
    }

    Group {
        title: "Running apps"

        Repeater {
            model: page.running

            SettingRow {
                id: runRow

                required property var modelData

                title: modelData.name

                ActionButton {
                    glyph: "󰐃"
                    text: "Pin"
                    onClicked: Dock.togglePin(runRow.modelData)
                }
            }
        }

        ReadOnlyRow {
            visible: page.running.length === 0
            title: "No other apps running"
            value: ""
        }
    }
}
