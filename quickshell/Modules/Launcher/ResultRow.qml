import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

// One launcher result: app icon (or symbol), title, subtitle, enter hint.
// The selection wash lives in the list's highlight, so the row stays flat;
// the wash hangs outward (the row insets its content by padControl), so the
// icon sits on the same column as the search field's glyph above.
// `tabular` for numeric titles (calculator results).
Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string iconName: ""
    property string glyph: ""
    property bool current: false
    property bool tabular: false

    signal clicked
    signal entered

    implicitHeight: Theme.resultHeight

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: root.entered() // not onEntered: scrolling under a still pointer must not steal selection
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.padControl
        anchors.rightMargin: Theme.padControl
        spacing: Theme.gapInline

        Item {
            Layout.preferredWidth: Theme.iconApp
            Layout.preferredHeight: Theme.iconApp

            IconImage {
                anchors.fill: parent
                visible: root.iconName !== ""
                source: root.iconName ? (Apps.iconSource(root.iconName) || Apps.iconSource("application-x-executable")) : ""
            }

            Icon {
                anchors.centerIn: parent
                visible: root.iconName === ""
                glyph: root.glyph
                size: Theme.iconXl
            }
        }

        Column {
            Layout.fillWidth: true

            Label {
                width: parent.width
                text: root.title
                font.pixelSize: Theme.textLg
                font.features: root.tabular ? { "tnum": 1 } : {}
            }

            Label {
                width: parent.width
                text: root.subtitle
                visible: text !== ""
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }
        }

        Icon {
            opacity: root.current ? 1 : 0
            glyph: "keyboard_return"
            color: Theme.textMuted

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animFast
                }
            }
        }
    }
}
