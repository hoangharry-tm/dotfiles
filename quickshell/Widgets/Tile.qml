import QtQuick
import qs.Common

// Control Center tile: icon + title + status, accent-filled when on.
// The right part (chevron) opens details when `expandable`.
Rectangle {
    id: root

    property string glyph: ""
    property string title: ""
    property string subtitle: ""
    property bool checked: false
    property bool expandable: false
    property bool expanded: false

    signal toggled
    signal expand

    implicitHeight: Theme.tileHeight
    radius: Theme.radiusMd
    color: checked ? Theme.primary : main.containsMouse ? Theme.hover : Theme.tile

    readonly property color fg: checked ? Theme.primaryText : Theme.text

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim
        }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Theme.padCard // = (height - badge) / 2: equal on all sides
        anchors.right: chevron.visible ? chevron.left : parent.right
        anchors.rightMargin: Theme.spaceSm
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spaceMd

        Rectangle {
            width: Theme.control
            height: Theme.control
            radius: Theme.radiusFull
            color: root.checked ? Qt.alpha(Theme.primaryText, 0.14) : Theme.tile
            anchors.verticalCenter: parent.verticalCenter

            Icon {
                anchors.centerIn: parent
                glyph: root.glyph
                size: Theme.icon
                color: root.fg
            }
        }

        Column {
            width: parent.width - Theme.control - Theme.spaceMd
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Label {
                width: parent.width
                text: root.title
                color: root.fg
                font.pixelSize: Theme.textMd
                font.weight: Font.DemiBold
            }

            Label {
                width: parent.width
                text: root.subtitle
                visible: text !== ""
                color: root.checked ? Qt.alpha(Theme.primaryText, 0.75) : Theme.textMuted
                font.pixelSize: Theme.textXs
            }
        }
    }

    MouseArea {
        id: main

        anchors.fill: parent
        anchors.rightMargin: chevron.visible ? chevron.width : 0
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }

    Clickable {
        id: chevron

        visible: root.expandable
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
