import QtQuick
import qs.Services
import qs.Widgets

SettingsPage {
    readonly property var hhmm: RegularExpressionValidator {
        regularExpression: /^([01]\d|2[0-3]):[0-5]\d$/
    }

    SettingsGroup {
        title: "Focus"

        SettingsRow {
            title: "Focus now"
            description: "Mute everything except critical notifications"

            SettingsSwitch {
                checked: Notifications.dnd
                onToggled: Notifications.dnd = !Notifications.dnd
            }
        }

        SettingsRow {
            title: "Default timer"
            description: "Remembers the last one you set"

            SettingsSlider {
                from: 5
                to: 120
                step: 5
                current: Settings.focusDefaultMin
                suffix: " min"
                onPicked: v => Settings.focusDefaultMin = v
            }
        }
    }

    SettingsGroup {
        title: "Schedule"

        SettingsRow {
            title: "Turn Focus on at set times"

            SettingsSwitch {
                checked: Settings.scheduleEnabled
                onToggled: Settings.scheduleEnabled = !Settings.scheduleEnabled
            }
        }

        SettingsRow {
            enabled: Settings.scheduleEnabled
            title: "From"
            description: "24-hour, HH:MM"

            SettingsField {
                text: Settings.scheduleStart
                validator: hhmm
                onCommitted: t => Settings.scheduleStart = t
            }
        }

        SettingsRow {
            enabled: Settings.scheduleEnabled
            title: "Until"
            description: "May be earlier than From (overnight)"

            SettingsField {
                text: Settings.scheduleEnd
                validator: hhmm
                onCommitted: t => Settings.scheduleEnd = t
            }
        }
    }

    SettingsGroup {
        title: "History"

        SettingsRow {
            title: "Keep across restarts"
            description: "Writes summaries and bodies to disk as plain text"

            SettingsSwitch {
                checked: Settings.persistHistory
                onToggled: Settings.persistHistory = !Settings.persistHistory
            }
        }

        SettingsRow {
            title: "Clear history"

            Button {
                text: "Clear"
                onClicked: Notifications.clearAll()
            }
        }
    }
}
