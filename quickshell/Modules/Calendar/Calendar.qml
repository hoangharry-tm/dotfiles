import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Widgets

// Month view under the clock. Scroll or ‹ › to change month.
PanelWindow {
    id: root

    required property ShellScreen modelData
    readonly property bool shown: Panels.isOpen("calendar", modelData.name)
    property date month: new Date()

    screen: modelData
    visible: shown
    anchors.top: true
    margins.top: Theme.barMargin + Theme.barHeight + 8
    implicitWidth: 320
    implicitHeight: sheet.implicitHeight
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.namespace: "qs-calendar"
    WlrLayershell.layer: WlrLayer.Overlay

    onShownChanged: if (shown)
        month = new Date()

    function shift(months) {
        month = new Date(month.getFullYear(), month.getMonth() + months, 1);
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Glass {
        id: sheet

        width: parent.width
        implicitHeight: column.implicitHeight + Theme.pad * 2

        MouseArea {
            anchors.fill: parent
            onWheel: w => root.shift(w.angleDelta.y > 0 ? -1 : 1)
        }

        ColumnLayout {
            id: column

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.pad
            spacing: 10

            Label {
                text: Qt.formatDateTime(clock.date, "dddd")
                color: Theme.primary
                font.pixelSize: Theme.textSm
                font.weight: Font.DemiBold
            }

            Label {
                Layout.topMargin: -8
                text: Qt.formatDateTime(clock.date, "d MMMM yyyy")
                font.pixelSize: Theme.textXl
                font.weight: Font.DemiBold
            }

            RowLayout {
                Layout.fillWidth: true

                Label {
                    Layout.fillWidth: true
                    text: Qt.formatDate(root.month, "MMMM yyyy")
                    color: Theme.textMuted
                }

                Repeater {
                    model: [{ g: "󰅁", d: -1 }, { g: "󰅂", d: 1 }]

                    Clickable {
                        required property var modelData

                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        radius: 13
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

                    implicitWidth: 36
                    implicitHeight: 32

                    Rectangle {
                        anchors.centerIn: parent
                        width: 30
                        height: 30
                        radius: 15
                        color: day.today ? Theme.primary : "transparent"
                    }

                    Label {
                        anchors.centerIn: parent
                        text: day.model.day
                        color: day.today ? Theme.primaryText : day.model.month === grid.month ? Theme.text : Qt.alpha(Theme.textMuted, 0.5)
                        font.pixelSize: Theme.textSm
                        font.weight: day.today ? Font.DemiBold : Font.Normal
                    }
                }
            }
        }
    }
}
