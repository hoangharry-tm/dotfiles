import QtQuick
import qs.Common
import qs.Services

SettingsPage {
    readonly property var coord: DoubleValidator {
        decimals: 4
        notation: DoubleValidator.StandardNotation
    }

    SettingsGroup {
        title: "Location"
        footnote: "In use: " + Location.city + ", " + Location.latitude.toFixed(2) + ", " + Location.longitude.toFixed(2)

        SettingsRow {
            title: "Detect automatically"
            description: "By IP address, refreshed every 6 hours"

            SettingsSwitch {
                checked: Settings.locAutoDetect
                onToggled: Settings.locAutoDetect = !Settings.locAutoDetect
            }
        }
    }

    SettingsGroup {
        title: "Fixed location"

        SettingsRow {
            enabled: !Settings.locAutoDetect
            title: "City"
            description: "Shown in the weather"

            SettingsField {
                text: Settings.locCity
                onCommitted: t => Settings.locCity = t
            }
        }

        SettingsRow {
            enabled: !Settings.locAutoDetect
            title: "Latitude"

            SettingsField {
                text: String(Settings.locLatitude)
                validator: coord
                onCommitted: t => Settings.locLatitude = Number(t)
            }
        }

        SettingsRow {
            enabled: !Settings.locAutoDetect
            title: "Longitude"

            SettingsField {
                text: String(Settings.locLongitude)
                validator: coord
                onCommitted: t => Settings.locLongitude = Number(t)
            }
        }

        SettingsRow {
            enabled: !Settings.locAutoDetect
            title: "Timezone"
            description: "IANA name, e.g. Europe/Berlin"

            SettingsField {
                text: Settings.locTimezone
                onCommitted: t => Settings.locTimezone = t
            }
        }
    }

    SettingsGroup {
        title: "Weather"

        SettingsRow {
            title: "Temperature"

            SettingsSegmented {
                segmentWidth: Theme.controlXl + Theme.spaceXl
                model: [
                    { label: "Celsius", value: false },
                    { label: "Fahrenheit", value: true }
                ]
                current: Settings.weatherFahrenheit
                onPicked: v => Settings.weatherFahrenheit = v
            }
        }
    }
}
