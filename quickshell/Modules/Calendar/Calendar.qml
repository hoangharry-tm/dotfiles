import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

// Month view under the clock. Scroll or ‹ › to change month.
PanelWindow {
    id: root

    required property ShellScreen modelData
    readonly property bool shown: Panels.isOpen("calendar", modelData.name)
    property date month: new Date()
    property var picked: null // day chosen in the grid; its events replace the default agenda

    screen: modelData
    visible: shown
    anchors.top: true
    exclusionMode: ExclusionMode.Ignore // margin is measured from the screen edge, not below the bar
    margins.top: Theme.popoverTop
    implicitWidth: Theme.calendarWidth
    implicitHeight: column.implicitHeight + Theme.padSheet * 2
    color: "transparent"
    WlrLayershell.namespace: "qs-calendar"
    WlrLayershell.layer: WlrLayer.Overlay

    onShownChanged: if (shown) {
        month = new Date();
        picked = null;
    }

    readonly property bool onCurrentMonth: month.getFullYear() === clock.date.getFullYear() && month.getMonth() === clock.date.getMonth()

    // ISO-8601 week number and day of year, for the footer.
    function weekNumber(d) {
        const t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
        t.setUTCDate(t.getUTCDate() + 4 - (t.getUTCDay() || 7));
        return Math.ceil(((t - Date.UTC(t.getUTCFullYear(), 0, 1)) / 86400000 + 1) / 7);
    }

    function dayOfYear(d) {
        return Math.round((new Date(d.getFullYear(), d.getMonth(), d.getDate()) - new Date(d.getFullYear(), 0, 1)) / 86400000) + 1;
    }

    function shift(months) {
        month = new Date(month.getFullYear(), month.getMonth() + months, 1);
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Glass {
        id: sheet

        anchors.fill: parent
        radius: Theme.radiusXl // = qs-calendar layer rule in niri/rules.kdl

        // Wheel flips months over the grid/header only; over the agenda it
        // must scroll the events (it used to flip months under the list).
        MouseArea {
            anchors.fill: parent
            onWheel: w => {
                const p = agenda.mapFromItem(this, w.x, w.y);
                if (agenda.visible && agenda.contains(p)) {
                    w.accepted = false;
                    return;
                }
                root.shift(w.angleDelta.y > 0 ? -1 : 1);
            }
        }

        ColumnLayout {
            id: column

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.padSheet
            spacing: Theme.spaceSm

            ColumnLayout {
                id: head

                Layout.fillWidth: true
                spacing: Theme.spaceSm

                // Header: today's date, large; hierarchy by size and color.
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spaceXs

                    Label {
                        text: Qt.formatDateTime(clock.date, "dddd")
                        color: Theme.primary
                        font.weight: Font.DemiBold
                    }

                    Label {
                        text: Qt.formatDateTime(clock.date, "d MMMM yyyy")
                        font.pixelSize: Theme.textXl
                        font.weight: Font.DemiBold
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.spaceSm
                    spacing: Theme.spaceXs

                    Label {
                        Layout.fillWidth: true
                        text: Qt.formatDate(root.month, "MMMM yyyy")
                        font.weight: Font.DemiBold
                    }

                    Clickable {
                        visible: !root.onCurrentMonth
                        Layout.preferredHeight: Theme.controlSm
                        Layout.preferredWidth: todayLabel.implicitWidth + Theme.padControl * 2
                        radius: Theme.radiusFull
                        onClicked: root.month = new Date()

                        Label {
                            id: todayLabel

                            anchors.centerIn: parent
                            text: "Today"
                            color: Theme.primary
                            font.pixelSize: Theme.textXs
                            font.weight: Font.DemiBold
                        }
                    }

                    Repeater {
                        model: [{ g: "󰅁", d: -1 }, { g: "󰅂", d: 1 }]

                        Clickable {
                            required property var modelData

                            Layout.preferredWidth: Theme.control
                            Layout.preferredHeight: Theme.control
                            radius: Theme.radiusFull
                            onClicked: root.shift(modelData.d)

                            Icon {
                                anchors.centerIn: parent
                                glyph: parent.modelData.g
                            }
                        }
                    }
                }

                DayOfWeekRow {
                    Layout.fillWidth: true
                    locale: grid.locale

                    delegate: Label {
                        required property string shortName

                        text: shortName.slice(0, 2)
                        horizontalAlignment: Text.AlignHCenter
                        color: Theme.textMuted
                        font.pixelSize: Theme.textXs
                    }
                }

                MonthGrid {
                    id: grid

                    Layout.fillWidth: true
                    month: root.month.getMonth()
                    year: root.month.getFullYear()
                    locale: Qt.locale("en_GB") // weeks start on Monday

                    delegate: Item {
                        id: day

                        required property var model
                        readonly property bool today: model.today
                        readonly property bool picked: root.picked !== null && root.picked.getTime() === model.date.getTime()

                        implicitWidth: Theme.control + Theme.spaceXs
                        implicitHeight: Theme.control + Theme.spaceXs

                        Rectangle {
                            anchors.centerIn: parent
                            width: Theme.control
                            height: Theme.control
                            radius: Theme.radiusFull
                            color: day.today ? Theme.primary : "transparent"
                            border.width: day.picked ? Theme.hairlineWidth : 0
                            border.color: Theme.primaryRing
                        }

                        Label {
                            anchors.centerIn: parent
                            text: day.model.day
                            color: day.today ? Theme.primaryText : day.model.month === grid.month ? Theme.text : Qt.alpha(Theme.textMuted, 0.5)
                            font.weight: day.today ? Font.DemiBold : Font.Normal
                        }

                        // One dot per calendar with events that day (max 3).
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: Theme.spaceMd
                            spacing: Theme.dot / 2

                            Repeater {
                                model: CalendarEvents.dotsOn(day.model.date)

                                Rectangle {
                                    required property color modelData

                                    width: Theme.dot
                                    height: Theme.dot
                                    radius: Theme.radiusFull
                                    color: day.today ? Theme.primaryText : modelData
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.picked = day.picked ? null : day.model.date
                        }
                    }
                }
            }

            Agenda {
                id: agenda

                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                picked: root.picked
                // Height budget: what the screen leaves under the popover, minus the fixed parts.
                // Compact: ~4.5 rows (the half row hints there is more to scroll),
                // and never past the screen on a short output.
                maxHeight: Math.min(Theme.rowHeightTall * Theme.agendaRows, Math.max(Theme.rowHeightTall * 2, root.modelData.height - Theme.popoverTop - Theme.edge - Theme.padSheet * 2 - head.implicitHeight - footer.implicitHeight - column.spacing * 2))
                onOpened: Panels.close()
            }

            Label {
                id: footer

                Layout.topMargin: Theme.spaceXs
                text: "Week " + root.weekNumber(clock.date) + "  \u00b7  Day " + root.dayOfYear(clock.date)
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }
        }
    }
}
