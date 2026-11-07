import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services

// One calendar event as a card body (bar hover card): calendar-coloured
// title, time range, location and a Join button when it has a meeting link.
ColumnLayout {
    id: root

    property var event: null

    Layout.fillWidth: true
    spacing: Theme.spaceXs

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.gapInline

        Rectangle {
            Layout.preferredWidth: Theme.spaceXs
            Layout.fillHeight: true
            radius: Theme.radiusFull
            color: root.event ? CalendarEvents.colorOf(root.event) : "transparent"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spaceXs

            Label {
                Layout.fillWidth: true
                text: root.event?.title ?? ""
                font.pixelSize: Theme.textLg
                font.weight: Font.DemiBold
            }

            Label {
                Layout.fillWidth: true
                text: root.event ? CalendarEvents.fmtTime(root.event.start) + " – " + CalendarEvents.fmtTime(root.event.end) + "  ·  " + root.event.calendar : ""
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }

            Label {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.event?.location ?? ""
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }
        }
    }

    Clickable {
        visible: root.event !== null && root.event.link !== ""
        Layout.topMargin: Theme.spaceXs
        Layout.preferredHeight: Theme.control
        Layout.fillWidth: true
        radius: Theme.radiusSm
        color: pressed ? Theme.toneAccentB : hovered ? Theme.toneAccentA : Theme.primary
        onClicked: CalendarEvents.open(root.event.link)

        Row {
            anchors.centerIn: parent
            spacing: Theme.gapInline

            Icon {
                glyph: "󰕧"
                color: Theme.primaryText
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: "Join"
                color: Theme.primaryText
                font.weight: Font.DemiBold
            }
        }
    }
}
