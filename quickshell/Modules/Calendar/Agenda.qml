import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Events under the month grid: a picked day, else today plus the next days
// that have something. Scrolls when it outgrows `maxHeight` (the popover's
// height budget). A row with a meeting link opens it on click.
Item {
    id: root

    property var picked: null      // Date of the day chosen in the grid, or null
    property int maxHeight: 0
    readonly property int days: 7  // how far the default agenda looks ahead

    signal opened

    implicitHeight: Math.min(list.implicitHeight, maxHeight)
    clip: true

    function heading(d, offset) {
        return offset === 0 ? "Today" : offset === 1 ? "Tomorrow" : Qt.formatDate(d, "ddd d MMM");
    }

    // [{label, events}], rebuilt only when events, the day, or the picked day change.
    readonly property var groups: {
        const today = new Date(CalendarEvents.now);
        today.setHours(0, 0, 0, 0);
        const out = [];
        if (picked) {
            const n = Math.round((new Date(picked.getFullYear(), picked.getMonth(), picked.getDate()) - today) / 86400000);
            out.push({ label: heading(picked, n), events: CalendarEvents.eventsOn(picked) });
            return out;
        }
        for (let i = 0; i < days; i++) {
            const d = new Date(today.getFullYear(), today.getMonth(), today.getDate() + i);
            const evs = CalendarEvents.eventsOn(d);
            if (evs.length || i === 0)
                out.push({ label: heading(d, i), events: evs });
        }
        return out;
    }

    Flickable {
        id: scroller

        anchors.fill: parent
        contentWidth: width
        contentHeight: list.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: Theme.pressDelay

        SmoothWheel {
            flick: scroller
        }

        ColumnLayout {
            id: list

            width: scroller.width
            spacing: Theme.spaceSm

            Label {
                visible: CalendarEvents.calendars.length === 0
                Layout.fillWidth: true
                text: "No calendars yet. Run calendar-add in a terminal."
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
                wrapMode: Text.WordWrap
            }

            Repeater {
                model: root.groups

                ColumnLayout {
                    id: group

                    required property var modelData

                    Layout.fillWidth: true
                    spacing: Theme.spaceXs

                    Label {
                        text: group.modelData.label
                        color: Theme.textMuted
                        font.pixelSize: Theme.textXs
                        font.weight: Font.DemiBold
                    }

                    Label {
                        visible: group.modelData.events.length === 0 && CalendarEvents.calendars.length > 0
                        text: "Nothing planned"
                        color: Theme.textMuted
                        font.pixelSize: Theme.textXs
                    }

                    Repeater {
                        model: group.modelData.events

                        Clickable {
                            id: row

                            required property var modelData
                            readonly property bool done: !modelData.allDay && modelData.end <= CalendarEvents.now

                            Layout.fillWidth: true
                            Layout.preferredHeight: modelData.location ? Theme.rowHeightTall : Theme.rowHeight
                            cursor: modelData.link ? Qt.PointingHandCursor : Qt.ArrowCursor
                            opacity: done ? 0.5 : 1 // finished events recede
                            onClicked: if (modelData.link) {
                                CalendarEvents.open(modelData.link);
                                root.opened();
                            }

                            Rectangle {
                                id: bar

                                anchors.left: parent.left
                                anchors.leftMargin: Theme.spaceXs
                                anchors.verticalCenter: parent.verticalCenter
                                width: Theme.spaceXs
                                height: parent.height - Theme.spaceSm * 2
                                radius: Theme.radiusFull
                                color: CalendarEvents.colorOf(row.modelData)
                            }

                            Label {
                                id: time

                                anchors.left: bar.right
                                anchors.leftMargin: Theme.spaceSm
                                anchors.verticalCenter: parent.verticalCenter
                                width: Theme.controlXl
                                text: row.modelData.allDay ? "All day" : CalendarEvents.fmtTime(row.modelData.start)
                                color: Theme.textMuted
                                font.pixelSize: Theme.textXs
                                font.features: { "tnum": 1 }
                            }

                            Column {
                                anchors.left: time.right
                                anchors.right: join.left
                                anchors.rightMargin: Theme.spaceSm
                                anchors.verticalCenter: parent.verticalCenter

                                Label {
                                    width: parent.width
                                    text: row.modelData.title
                                    font.weight: Font.DemiBold
                                }

                                Label {
                                    width: parent.width
                                    visible: text !== ""
                                    text: row.modelData.location
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.textXs
                                }
                            }

                            Icon {
                                id: join

                                anchors.right: parent.right
                                anchors.rightMargin: Theme.spaceSm
                                anchors.verticalCenter: parent.verticalCenter
                                visible: row.modelData.link !== ""
                                glyph: "󰕧"
                                color: Theme.primary
                            }
                        }
                    }
                }
            }
        }
    }
}
