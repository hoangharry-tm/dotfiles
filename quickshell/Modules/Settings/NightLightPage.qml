import QtQuick
import qs.Common
import qs.Services

SettingsPage {
    // First group: no heading, the page title already names it.
    SettingsGroup {

        SettingsRow {
            title: "Mode"
            description: "Auto tints between sunset and sunrise"

            SettingsSegmented {
                segmentWidth: Theme.controlXl + Theme.spaceMd
                model: [
                    { label: "Off", value: "off" },
                    { label: "On", value: "on" },
                    { label: "Auto", value: "auto" }
                ]
                current: Settings.nightMode
                onPicked: v => NightLight.setMode(v)
            }
        }
    }

    SettingsGroup {
        title: "Colour temperature"

        SettingsRow {
            enabled: Settings.nightMode !== "off"
            title: "Warm"
            description: "While tinted; lower is warmer"

            SettingsSlider {
                from: 2000
                to: 5000
                step: 100
                current: Settings.nightWarmTemp
                suffix: " K"
                onPicked: v => Settings.nightWarmTemp = v
            }
        }

        SettingsRow {
            enabled: Settings.nightMode === "auto"
            title: "Daylight"
            description: "Auto mode only"

            SettingsSlider {
                from: 4000
                to: 6500
                step: 100
                current: Settings.nightDayTemp
                suffix: " K"
                onPicked: v => Settings.nightDayTemp = v
            }
        }
    }
}
