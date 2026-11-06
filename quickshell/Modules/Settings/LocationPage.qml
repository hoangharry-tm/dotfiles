import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

ColumnLayout {
    spacing: Theme.gapSection

    readonly property var coord: DoubleValidator {
        decimals: 4
        notation: DoubleValidator.StandardNotation
    }

    Group {
        title: "Location"

        SettingRow {
            title: "Detect automatically"
            subtitle: "By IP address (ipinfo.io), refreshed every 6 hours"

            SwitchControl {
                checked: Settings.locAutoDetect
                onToggled: Settings.locAutoDetect = !Settings.locAutoDetect
            }
        }

        ReadOnlyRow {
            title: "In use"
            value: Location.city + "  " + Location.latitude.toFixed(2) + ", " + Location.longitude.toFixed(2)
        }
    }

    Group {
        title: "Fixed location"

        SettingRow {
            title: "City"
            subtitle: "Shown in the weather"

            FieldControl {
                text: Settings.locCity
                onCommitted: t => Settings.locCity = t
            }
        }

        SettingRow {
            title: "Latitude"

            FieldControl {
                text: String(Settings.locLatitude)
                validator: coord
                mono: true
                onCommitted: t => Settings.locLatitude = Number(t)
            }
        }

        SettingRow {
            title: "Longitude"

            FieldControl {
                text: String(Settings.locLongitude)
                validator: coord
                mono: true
                onCommitted: t => Settings.locLongitude = Number(t)
            }
        }

        SettingRow {
            title: "Timezone"
            subtitle: "IANA name, e.g. Europe/Berlin"

            FieldControl {
                text: Settings.locTimezone
                mono: true
                onCommitted: t => Settings.locTimezone = t
            }
        }
    }

    Group {
        title: "Weather"

        SettingRow {
            title: "Temperature"

            Segmented {
                width: Theme.launcherWidth / 3
                model: [
                    { glyph: "󰔄", label: "Celsius", value: false },
                    { glyph: "󰔅", label: "Fahrenheit", value: true }
                ]
                current: Settings.weatherFahrenheit
                onPicked: v => Settings.weatherFahrenheit = v
            }
        }
    }
}
