import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services

ColumnLayout {
    spacing: Theme.gapSection

    function synced(ms) {
        return ms > 0 ? Qt.formatDateTime(new Date(ms), "ddd d MMM, " + (Settings.clock24h ? "HH:mm" : "h:mm AP")) : "never";
    }

    // Names and status only: the secret URLs never leave sops.
    Group {
        title: "Calendars"

        Repeater {
            model: CalendarEvents.calendars

            ReadOnlyRow {
                required property var modelData

                title: modelData.name
                value: modelData.ok ? "synced" : modelData.error
            }
        }

        ReadOnlyRow {
            visible: CalendarEvents.calendars.length === 0
            title: "No calendars"
            value: "none added"
        }

        SettingRow {
            title: "Refresh"
            subtitle: "Last synced " + synced(CalendarEvents.syncedAt) + ", then every 10 min"

            ActionButton {
                glyph: "󰑐"
                text: CalendarEvents.syncing ? "Syncing" : "Refresh now"
                onClicked: CalendarEvents.refresh()
            }
        }
    }

    Group {
        title: "Reminders and bar"

        SettingRow {
            title: "Reminder toast"
            subtitle: "Minutes before an event starts; 0 turns it off"

            SettingSlider {
                from: 0
                to: 60
                step: 5
                current: Settings.calendarRemindMin
                suffix: " min"
                onPicked: v => Settings.calendarRemindMin = v
            }
        }

        SettingRow {
            title: "Bar chip window"
            subtitle: "Show the next event this long before it starts"

            SettingSlider {
                from: 5
                to: 120
                step: 5
                current: Settings.calendarChipMin
                suffix: " min"
                onPicked: v => Settings.calendarChipMin = v
            }
        }
    }

    Group {
        title: "How to add"

        ReadOnlyRow {
            title: "Add a calendar"
            subtitle: "Paste its secret iCal (ICS) address; view only"
            value: "calendar-add"
        }

        ReadOnlyRow {
            title: "Remove one"
            value: "calendar-remove <name>"
        }
    }
}
