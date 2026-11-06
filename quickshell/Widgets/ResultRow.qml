import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Common

// One launcher result: app icon (or glyph), title, subtitle, enter hint.
// The selection wash lives in the list's highlight, so the row stays flat.
Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string iconName: ""
    property string glyph: ""
    property bool current: false

    signal clicked
    signal entered

    implicitHeight: 52

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: root.entered() // not onEntered: scrolling under a still pointer must not steal selection
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.pad
        anchors.rightMargin: Theme.pad
        spacing: Theme.pad

        Item {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30

            IconImage {
                anchors.fill: parent
                visible: root.iconName !== ""
                source: root.iconName ? Quickshell.iconPath(root.iconName, "application-x-executable") : ""
            }

            Icon {
                anchors.centerIn: parent
                visible: root.iconName === ""
                glyph: root.glyph
                size: Theme.iconLg + 4
                color: Theme.primary
            }
        }

        Column {
            Layout.fillWidth: true

            Label {
                width: parent.width
                text: root.title
                font.pixelSize: Theme.textLg
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
            glyph: "󰌑"
            color: Theme.textMuted

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animFast
                }
            }
        }
    }
}
