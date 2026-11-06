import QtQuick
import Quickshell
import qs.Common
import qs.Widgets

// Date and time; click for the calendar.
BarChip {
    id: root

    required property string screenName

    active: Panels.isOpen("calendar", screenName)
    onClicked: Panels.toggle("calendar", screenName)

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Label {
        text: Qt.formatDateTime(clock.date, "ddd d MMM") + "  \u00b7  " + Qt.formatDateTime(clock.date, "HH:mm")
        font.weight: Font.DemiBold
    }
}
