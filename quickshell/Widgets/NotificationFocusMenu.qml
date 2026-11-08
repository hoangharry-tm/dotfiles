import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services

// Small menu for the Focus tile: timed Focus, the schedule, history opt-in.
// Place it under the tile; `open` shows it, any choice closes it.
Rectangle {
    id: root

    property bool open: false

    visible: open
    implicitWidth: col.implicitWidth + Theme.spaceXs * 2   // inset spaceXs: rows radiusMd - spaceXs = radiusSm
    implicitHeight: col.implicitHeight + Theme.spaceXs * 2
    radius: Theme.radiusMd
    color: Theme.glassSolid // QML-drawn popup: flat, like toasts
    border.width: Theme.hairlineWidth
    border.color: Theme.hairline

    component MenuRow: Clickable {
        id: row

        property string text
        property bool checked: false
        property bool toggle: false

        Layout.fillWidth: true
        implicitWidth: label.implicitWidth + Theme.padControl * 2 + (toggle ? Theme.icon + Theme.gapInline : 0)
        implicitHeight: Theme.control
        radius: Theme.radiusSm

        Label {
            id: label

            anchors.left: parent.left
            anchors.leftMargin: Theme.padControl
            anchors.verticalCenter: parent.verticalCenter
            text: row.text
            font.features: {
                "tnum": 1 // times in "Focus until 07:00"
            }
        }

        Icon {
            visible: row.toggle
            anchors.right: parent.right
            anchors.rightMargin: Theme.padControl
            anchors.verticalCenter: parent.verticalCenter
            glyph: row.checked ? "check" : ""
            color: Theme.text
        }
    }

    ColumnLayout {
        id: col

        anchors.centerIn: parent
        spacing: 0

        MenuRow {
            text: "Focus timer…"
            onClicked: {
                root.open = false;
                FocusTimer.openCard();
            }
        }

        MenuRow {
            text: "Focus for 1 hour"
            onClicked: {
                Notifications.focusFor(60);
                root.open = false;
            }
        }

        MenuRow {
            text: "Focus until " + Notifications.scheduleEnd
            onClicked: {
                Notifications.focusUntilTime(Notifications.scheduleEnd);
                root.open = false;
            }
        }

        MenuRow {
            toggle: true
            checked: Notifications.scheduleEnabled
            text: "Schedule " + Notifications.scheduleStart + " - " + Notifications.scheduleEnd
            onClicked: Notifications.setSchedule(!Notifications.scheduleEnabled)
        }

        MenuRow {
            toggle: true
            checked: Notifications.persistHistory
            text: "Keep history after restart"
            onClicked: Notifications.setPersist(!Notifications.persistHistory)
        }
    }
}
