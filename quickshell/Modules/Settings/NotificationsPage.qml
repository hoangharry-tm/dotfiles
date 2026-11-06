import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services

ColumnLayout {
    spacing: Theme.gapSection

    readonly property var hhmm: RegularExpressionValidator {
        regularExpression: /^([01]\d|2[0-3]):[0-5]\d$/
    }

    Group {
        title: "Focus"

        SettingRow {
            title: "Focus now"
            subtitle: "Mute everything except critical notifications"

            SwitchControl {
                checked: Notifications.dnd
                onToggled: Notifications.dnd = !Notifications.dnd
            }
        }

        SettingRow {
            title: "Schedule"
            subtitle: "Turn Focus on and off at set times"

            SwitchControl {
                checked: Settings.scheduleEnabled
                onToggled: Settings.scheduleEnabled = !Settings.scheduleEnabled
            }
        }

        SettingRow {
            title: "From"
            subtitle: "HH:MM, 24-hour"

            FieldControl {
                text: Settings.scheduleStart
                validator: hhmm
                mono: true
                onCommitted: t => Settings.scheduleStart = t
            }
        }

        SettingRow {
            title: "Until"
            subtitle: "May be earlier than From (overnight)"

            FieldControl {
                text: Settings.scheduleEnd
                validator: hhmm
                mono: true
                onCommitted: t => Settings.scheduleEnd = t
            }
        }
    }

    Group {
        title: "History"

        SettingRow {
            title: "Keep history across restarts"
            subtitle: "Writes summaries and bodies to disk as plain text"

            SwitchControl {
                checked: Settings.persistHistory
                onToggled: Settings.persistHistory = !Settings.persistHistory
            }
        }

        SettingRow {
            title: "Clear history"

            ActionButton {
                glyph: "󰩺"
                text: "Clear"
                onClicked: Notifications.clearAll()
            }
        }
    }
}
