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
            spacing: Theme.gapSection

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
                        color: Theme.textMuted
                        font.weight: Theme.weightEmphasis
                    }

                    Label {
                        text: Qt.formatDateTime(clock.date, "d MMMM yyyy")
                        font.pixelSize: Theme.textXl
                        font.weight: Theme.weightTitle
                        font.features: { "tnum": 1 }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.spaceSm
                    spacing: 0

                    Label {
                        Layout.fillWidth: true
                        text: Qt.formatDate(root.month, "MMMM yyyy")
                        font.weight: Theme.weightEmphasis
                        font.features: { "tnum": 1 }
                    }

                    Button {
                        visible: !root.onCurrentMonth
                        text: "Today"
                        onClicked: root.month = new Date()
                    }

                    Button {
                        glyph: "chevron_left"
                        tip: "Previous month"
                        onClicked: root.shift(-1)
                    }

                    Button {
                        glyph: "chevron_right"
                        tip: "Next month"
                        onClicked: root.shift(1)
                    }
                }

                // Header and grid both fill the sheet width, so the seven
                // columns of each are the same columns.
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
                        readonly property bool inMonth: model.month === grid.month
                        readonly property bool picked: root.picked !== null && root.picked.getTime() === model.date.getTime()

                        implicitWidth: Theme.control + Theme.spaceXs
                        implicitHeight: Theme.control + Theme.spaceXs

                        // Days of the neighbouring months stay empty (the grid keeps its rhythm).
                        // Today is the one filled accent day; a picked day is a neutral disc.
                        Surface {
                            visible: day.inMonth
                            anchors.centerIn: parent
                            width: Theme.control
                            height: Theme.control
                            radius: Theme.radiusFull
                            variant: day.today ? "accent" : "on"
                            opacity: day.today || day.picked ? 1 : 0 // picked (neutral "on") and today share one disc
                        }

                        Label {
                            visible: day.inMonth
                            anchors.centerIn: parent
                            text: day.model.day
                            font.features: { "tnum": 1 }
                            color: day.today ? Theme.onAccent : Theme.text
                            font.weight: day.today ? Theme.weightEmphasis : Font.Normal
                        }

                        // One dot per calendar with events that day (max 3).
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: Theme.spaceMd
                            spacing: Theme.dot / 2

                            Repeater {
                                model: day.inMonth ? CalendarEvents.dotsOn(day.model.date) : []

                                Rectangle {
                                    required property color modelData

                                    width: Theme.dot
                                    height: Theme.dot
                                    radius: Theme.radiusFull
                                    color: day.today ? Theme.onAccent : modelData
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

                Layout.leftMargin: Theme.columnA
                text: "Week " + root.weekNumber(clock.date) + "  \u00b7  Day " + root.dayOfYear(clock.date)
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
                font.features: { "tnum": 1 }
            }
        }
    }
}
