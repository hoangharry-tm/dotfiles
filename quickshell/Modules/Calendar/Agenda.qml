import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Events under the month grid: a picked day, else today plus the next days
// that have something, one Group per day under a muted header on column A.
// Scrolls when it outgrows `maxHeight` (the popover's
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
            spacing: Theme.gapSection

            Label {
                visible: CalendarEvents.calendars.length === 0
                Layout.fillWidth: true
                Layout.leftMargin: Theme.columnA
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
                    readonly property bool empty: modelData.events.length === 0

                    Layout.fillWidth: true
                    spacing: Theme.spaceSm

                    // Day header: muted section label on column A, above its group.
                    Label {
                        Layout.leftMargin: Theme.columnA
                        text: group.modelData.label
                        color: Theme.textMuted
                        font.pixelSize: Theme.textXs
                        font.weight: Theme.weightEmphasis
                    }

                    Label {
                        Layout.leftMargin: Theme.columnA
                        visible: group.empty && CalendarEvents.calendars.length > 0
                        text: "Nothing planned"
                        color: Theme.textMuted
                        font.pixelSize: Theme.textXs
                    }

                    // One Group per day (a Group with no rows would still draw), so only built when there are events.
                    Repeater {
                        model: group.empty ? [] : [group.modelData.events]

                        Group {
                            id: events

                            required property var modelData

                            Layout.fillWidth: true

                            Repeater {
                                model: events.modelData

                                Clickable {
                                    id: row

                                    required property var modelData
                                    readonly property bool done: !modelData.allDay && modelData.end <= CalendarEvents.now

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: modelData.location ? Theme.rowHeightTall : Theme.rowHeight
                                    cursor: modelData.link ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: if (modelData.link) {
                                        CalendarEvents.open(modelData.link);
                                        root.opened();
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: Theme.padControl
                                        anchors.rightMargin: Theme.padControl
                                        spacing: Theme.gapInline

                                        // Data colour: a small bar, never a fill.
                                        Rectangle {
                                            Layout.preferredWidth: Theme.spaceXs
                                            Layout.fillHeight: true
                                            Layout.topMargin: Theme.spaceSm
                                            Layout.bottomMargin: Theme.spaceSm
                                            radius: Theme.radiusFull
                                            color: CalendarEvents.colorOf(row.modelData)
                                        }

                                        Label {
                                            Layout.preferredWidth: Theme.controlXl
                                            text: row.modelData.allDay ? "All day" : CalendarEvents.fmtTime(row.modelData.start)
                                            color: Theme.textMuted
                                            font.pixelSize: Theme.textXs
                                            font.features: { "tnum": 1 }
                                        }

                                        // Finished events recede by value (muted title), never by opacity: muted text keeps its contrast.
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 0

                                            Label {
                                                Layout.fillWidth: true
                                                text: row.modelData.title
                                                color: row.done ? Theme.textMuted : Theme.text
                                            }

                                            Label {
                                                Layout.fillWidth: true
                                                visible: text !== ""
                                                text: row.modelData.location
                                                color: Theme.textMuted
                                                font.pixelSize: Theme.textXs
                                            }
                                        }

                                        Icon {
                                            visible: row.modelData.link !== ""
                                            glyph: "videocam"
                                            color: Theme.textMuted
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
