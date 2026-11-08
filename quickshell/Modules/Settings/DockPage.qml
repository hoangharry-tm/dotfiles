import QtQuick
import qs.Services
import qs.Widgets

SettingsPage {
    id: page

    // Same builder the dock uses, so names/icons/running state match.
    readonly property var apps: Dock.build(Niri.windows, Niri.mru, Settings.dockPinned)
    readonly property var pinned: apps.filter(a => a.pinned)
    readonly property var running: apps.filter(a => !a.pinned)

    SettingsGroup {
        SettingsRow {
            title: "Show dock"
            description: "Launcher and switcher at the bottom edge"

            SettingsSwitch {
                checked: Settings.dockEnabled
                onToggled: Settings.dockEnabled = !Settings.dockEnabled
            }
        }

        SettingsRow {
            title: "Auto-hide"
            description: "Reveal when the pointer touches the edge"

            SettingsSwitch {
                checked: Settings.dockAutoHide
                onToggled: Settings.dockAutoHide = !Settings.dockAutoHide
            }
        }

        SettingsRow {
            title: "Style"
            description: Settings.dockStyle === "macos" ? "Magnifying wave, launch hop, drag to reorder" : "A quiet lift"

            SettingsSegmented {
                model: [
                    { label: "macOS", value: "macos" },
                    { label: "Minimal", value: "minimal" }
                ]
                current: Settings.dockStyle
                onPicked: v => Settings.dockStyle = v
            }
        }

        SettingsRow {
            title: "Icon size"

            SettingsSlider {
                from: 32
                to: 64
                step: 4
                current: Settings.dockIconSize
                suffix: " px"
                onPicked: v => Settings.dockIconSize = v
            }
        }
    }

    SettingsGroup {
        title: "Pinned"
        empty: page.pinned.length === 0 ? "Pin a running app below" : ""

        Repeater {
            model: page.pinned

            SettingsRow {
                id: row

                required property var modelData
                required property int index

                title: modelData.name

                Button {
                    glyph: "keyboard_arrow_up"
                    enabled: row.index > 0
                    opacity: enabled ? 1 : 0 // keeps the columns of the other rows aligned
                    tip: "Move up"
                    onClicked: Dock.movePin(row.modelData.key, -1)
                }

                Button {
                    glyph: "keyboard_arrow_down"
                    enabled: row.index < page.pinned.length - 1
                    opacity: enabled ? 1 : 0
                    tip: "Move down"
                    onClicked: Dock.movePin(row.modelData.key, 1)
                }

                Button {
                    text: "Unpin"
                    onClicked: Dock.togglePin(row.modelData)
                }
            }
        }
    }

    SettingsGroup {
        title: "Running"
        empty: page.running.length === 0 ? "No other apps running" : ""

        Repeater {
            model: page.running

            SettingsRow {
                id: runRow

                required property var modelData

                title: modelData.name

                Button {
                    text: "Pin"
                    onClicked: Dock.togglePin(runRow.modelData)
                }
            }
        }
    }
}
