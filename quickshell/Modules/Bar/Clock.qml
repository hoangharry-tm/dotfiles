import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

// Date and time; click for the calendar. Last-resort collapse (level 1)
// drops the weekday.
BarChip {
    id: root

    required property string screenName

    readonly property string time: Qt.formatDateTime(clock.date, Settings.clock24h ? "HH:mm" : "h:mm AP")
    readonly property var texts: [Qt.formatDateTime(clock.date, "ddd d MMM") + "  \u00b7  " + time, Qt.formatDateTime(clock.date, "d MMM") + "  \u00b7  " + time]
    // Both widths from text metrics, so the bar can pick a level before it lays out.
    readonly property var widths: [chipWidth(full.width), chipWidth(short.width)]

    active: Panels.isOpen("calendar", screenName)
    onClicked: Panels.toggle("calendar", screenName)

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    TextMetrics {
        id: full

        font: label.font
        text: root.texts[0]
    }

    TextMetrics {
        id: short

        font: label.font
        text: root.texts[1]
    }

    Label {
        id: label

        text: root.texts[Math.min(root.level, 1)]
        font.weight: Font.DemiBold
    }
}
