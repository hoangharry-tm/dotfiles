import QtQuick
import QtQuick.Layouts
import qs.Common

// The one list row (iOS inset-grouped idiom), meant to sit inside a Group:
// no resting fill, only the hover/press wash. Leading icon in a fixed box,
// title (+ muted subtitle), optional muted meta (signal, battery %, volume;
// tabular), then one trailing slot: spinner while `busy`, a check when
// `marked`, else the quiet `trailingGlyph`.
//   marked    the chosen one (connected, default output): filled icon, check,
//             DemiBold name. No colour, no fill.
//   selected  legacy "current page" wash for sidebars (Settings, device card).
Clickable {
    id: root

    property string glyph: ""
    property string title: ""
    property string subtitle: ""
    property string meta: ""
    property string trailingGlyph: ""
    property bool marked: false
    property bool selected: false
    property bool busy: false

    implicitHeight: subtitle ? Theme.rowHeightTall : Theme.rowHeight
    radius: Theme.radiusSm
    active: selected
    activeColor: Theme.toneHover

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.padControl
        anchors.rightMargin: Theme.padControl
        spacing: Theme.gapInline

        Icon {
            glyph: root.glyph
            filled: root.marked || root.selected
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Label {
                Layout.fillWidth: true
                text: root.title
                font.weight: root.marked || root.selected ? Theme.weightEmphasis : Font.Normal
            }

            Label {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.subtitle
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }
        }

        Label {
            visible: root.meta !== ""
            text: root.meta
            color: Theme.textMuted
            font.pixelSize: Theme.textSm
            font.features: {
                "tnum": 1
            }
        }

        // Trailing slot, always an icon-wide box so rows align.
        Item {
            visible: root.busy || root.marked || root.trailingGlyph !== ""
            Layout.preferredWidth: Theme.icon
            Layout.preferredHeight: Theme.icon

            Icon {
                anchors.centerIn: parent
                glyph: root.busy ? "progress_activity" : root.marked ? "check" : root.trailingGlyph
                size: root.busy || root.marked ? Theme.icon : Theme.iconSm
                color: root.marked && !root.busy ? Theme.text : Theme.textMuted

                RotationAnimation on rotation {
                    running: root.busy && Theme.motionScale > 0
                    from: 0
                    to: 360
                    duration: Theme.animSpin
                    loops: Animation.Infinite
                    onRunningChanged: if (!running)
                        parent.rotation = 0
                }
            }
        }
    }
}
