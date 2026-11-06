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
    margins.top: Theme.popoverTop
    implicitWidth: 336
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
        implicitHeight: column.implicitHeight + Theme.padSheet * 2
        radius: Theme.radiusXl // = qs-calendar layer rule in niri/rules.kdl

        MouseArea {
            anchors.fill: parent
            onWheel: w => root.shift(w.angleDelta.y > 0 ? -1 : 1)
        }

        ColumnLayout {
            id: column

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.padSheet
            spacing: Theme.spaceSm

            Label {
                text: Qt.formatDateTime(clock.date, "dddd")
                color: Theme.primary
                font.pixelSize: Theme.textSm
                font.weight: Font.DemiBold
            }

            Label {
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

                    implicitWidth: Theme.control + Theme.spaceXs
                    implicitHeight: Theme.control + Theme.spaceXs

                    Rectangle {
                        anchors.centerIn: parent
                        width: Theme.control
                        height: Theme.control
                        radius: Theme.radiusFull
                        color: day.today ? Theme.primary : "transparent"
                    }

                    Label {
                        anchors.centerIn: parent
                        text: day.model.day
                        color: day.today ? Theme.primaryText : day.model.month === grid.month ? Theme.text : Qt.alpha(Theme.textMuted, 0.5)
                        font.weight: day.today ? Font.DemiBold : Font.Normal
                    }
                }
            }
        }
    }
}
