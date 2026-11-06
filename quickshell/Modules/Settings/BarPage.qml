import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

ColumnLayout {
    spacing: Theme.gapSection

    Group {
        title: "Clock"

        SettingRow {
            title: "Time format"

            Segmented {
                width: Theme.launcherWidth / 3
                model: [
                    { glyph: "󰥔", label: "24-hour", value: true },
                    { glyph: "󰥔", label: "12-hour", value: false }
                ]
                current: Settings.clock24h
                onPicked: v => Settings.clock24h = v
            }
        }
    }

    Group {
        title: "Layout"

        ReadOnlyRow {
            title: "Items"
            value: "collapse by priority to fit"
        }
    }
}
