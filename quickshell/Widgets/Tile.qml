import QtQuick
import qs.Common

// Control Center tile. Wide: icon badge + title + status, chevron opens
// details when `expandable`. Compact: icon badge over a short label.
// Tonal gradient; richer container tone with an accent badge when on (Surface).
Item {
    id: root

    property string glyph: ""
    property string title: ""
    property string subtitle: ""
    property bool checked: false
    property bool compact: false
    property bool expandable: false
    property bool expanded: false
    property bool fuse: true    // expanded: square bottom corners to meet its list (off when the list sits apart)

    signal toggled
    signal expand
    signal held         // right-click or long-press: a secondary menu

    readonly property color fg: checked ? Theme.onTone : Theme.text
    readonly property color fgMuted: checked ? Theme.onToneMuted : Theme.textMuted
    // An expanded tile fuses with its list below: bottom corners go square.
    readonly property real bottomRadius: expanded && fuse ? 0 : radius

    implicitHeight: compact ? stack.implicitHeight + Theme.padControl * 2 : Theme.tileHeight
    readonly property real radius: Theme.radiusMd

    Surface {
        anchors.fill: parent
        radius: root.radius
        bottomLeftRadius: root.bottomRadius
        bottomRightRadius: root.bottomRadius
        variant: root.checked ? "on" : "rest"
        hovered: main.containsMouse
        pressed: main.pressed
    }

    // Wide layout
    Row {
        visible: !root.compact
        anchors.left: parent.left
        anchors.leftMargin: Theme.padCard // = (height - badge) / 2: equal on all sides
        anchors.right: chevron.visible ? chevron.left : parent.right
        anchors.rightMargin: Theme.spaceSm
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spaceMd

        IconBadge {
            anchors.verticalCenter: parent.verticalCenter
            glyph: root.glyph
            on: root.checked
        }

        Column {
            width: parent.width - Theme.control - Theme.spaceMd
            anchors.verticalCenter: parent.verticalCenter

            Label {
                width: parent.width
                text: root.title
                color: root.fg
                font.weight: Font.DemiBold
            }

            Label {
                width: parent.width
                text: root.subtitle
                visible: text !== ""
                color: root.fgMuted
                font.pixelSize: Theme.textXs
            }
        }
    }

    // Compact layout
    Column {
        id: stack

        visible: root.compact
        anchors.centerIn: parent
        width: parent.width - Theme.padControl * 2
        spacing: Theme.spaceXs

        IconBadge {
            anchors.horizontalCenter: parent.horizontalCenter
            glyph: root.glyph
            on: root.checked
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: root.title
            color: root.fg
            font.pixelSize: Theme.textXs
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: main

        anchors.fill: parent
        anchors.rightMargin: chevron.visible ? chevron.width + Theme.spaceSm * 2 : 0
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: m => m.button === Qt.RightButton ? root.held() : root.toggled()
        onPressAndHold: root.held()
    }

    Clickable {
        id: chevron

        visible: root.expandable && !root.compact
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: Theme.spaceSm
        width: Theme.control
        radius: Theme.radiusSm
        onClicked: root.expand()

        Icon {
            anchors.centerIn: parent
            glyph: "󰅂"
            color: root.fg
            rotation: root.expanded ? 90 : 0

            Behavior on rotation {
                NumberAnimation {
                    duration: Theme.anim
                    easing.type: Theme.easing
                }
            }
        }
    }
}
