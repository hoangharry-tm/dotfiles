import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

ColumnLayout {
    spacing: Theme.gapSection

    Group {
        title: "Mode"

        SettingRow {
            title: "Night light"
            subtitle: "Auto tints between sunset and sunrise at your location"

            Segmented {
                width: Theme.launcherWidth / 2
                model: [
                    { glyph: "󰖙", label: "Off", value: "off" },
                    { glyph: "󰖔", label: "On", value: "on" },
                    { glyph: "󰔛", label: "Auto", value: "auto" }
                ]
                current: Settings.nightMode
                onPicked: v => NightLight.setMode(v)
            }
        }
    }

    Group {
        title: "Colour temperature"

        SettingRow {
            title: "Warm"
            subtitle: "While tinted; lower is warmer"

            SettingSlider {
                from: 2000
                to: 5000
                step: 100
                current: Settings.nightWarmTemp
                suffix: " K"
                onPicked: v => Settings.nightWarmTemp = v
            }
        }

        SettingRow {
            title: "Daylight"
            subtitle: "Auto mode only"

            SettingSlider {
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
