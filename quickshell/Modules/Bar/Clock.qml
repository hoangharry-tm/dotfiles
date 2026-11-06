import QtQuick
import Quickshell
import qs.Common
import qs.Widgets

// Date and time; click for the calendar.
Clickable {
    id: root

    required property string screenName

    implicitWidth: label.implicitWidth + 20
    implicitHeight: 26
    active: Panels.isOpen("calendar", screenName)
    onClicked: Panels.toggle("calendar", screenName)

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Label {
        id: label

        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "ddd d MMM   HH:mm")
        font.weight: Font.DemiBold
    }
}
