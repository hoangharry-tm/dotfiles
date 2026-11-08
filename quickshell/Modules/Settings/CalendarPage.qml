import QtQuick
import qs.Services
import qs.Widgets

SettingsPage {
    function synced(ms) {
        return ms > 0 ? Qt.formatDateTime(new Date(ms), "ddd d MMM, " + (Settings.clock24h ? "HH:mm" : "h:mm AP")) : "never";
    }

    // Names and status only: the secret URLs never leave sops.
    SettingsGroup {
        title: "Calendars"
        empty: CalendarEvents.calendars.length === 0 ? "No calendars" : ""
        footnote: "Add or remove calendars in a terminal with calendar-add and calendar-remove."

        Repeater {
            model: CalendarEvents.calendars

            SettingsRow {
                required property var modelData

                title: modelData.name
                value: modelData.ok ? "Synced" : modelData.error
            }
        }

        SettingsRow {
            title: "Refresh"
            description: "Last synced " + synced(CalendarEvents.syncedAt) + ", then every 10 min"

            Button {
                text: "Refresh now"
                glyph: "refresh"
                busy: CalendarEvents.syncing
                onClicked: CalendarEvents.refresh()
            }
        }
    }

    SettingsGroup {
        title: "Reminders"

        SettingsRow {
            title: "Reminder toast"
            description: "Minutes before an event; 0 turns it off"

            SettingsSlider {
                from: 0
                to: 60
                step: 5
                current: Settings.calendarRemindMin
                suffix: " min"
                onPicked: v => Settings.calendarRemindMin = v
            }
        }

        SettingsRow {
            title: "Bar chip window"
            description: "Show the next event this long before it starts"

            SettingsSlider {
                from: 5
                to: 120
                step: 5
                current: Settings.calendarChipMin
                suffix: " min"
                onPicked: v => Settings.calendarChipMin = v
            }
        }
    }
}
