import QtQuick
import qs.Common
import qs.Widgets

// The one on/off control (Apple idiom): a light knob on a neutral track when
// off, on the accent when on (state). The knob is fillSolid, so it reads as a
// physical white knob in light mode and stays light in dark mode.
// Controlled: it only reports `toggled`; the owner flips the value.
Item {
    id: root

    property bool checked: false

    signal toggled

    readonly property int thumb: Theme.controlSm - Theme.spaceXs

    implicitWidth: Theme.controlLg
    implicitHeight: Theme.controlSm

    Surface {
        anchors.fill: parent
        radius: Theme.radiusFull
        variant: root.checked ? "accent" : "track"
        hovered: area.containsMouse
    }

    Rectangle {
        x: root.checked ? root.width - width - Theme.spaceXs / 2 : Theme.spaceXs / 2
        anchors.verticalCenter: parent.verticalCenter
        width: root.thumb
        height: root.thumb
        radius: Theme.radiusFull
        color: root.checked ? Theme.onAccent : Theme.fillSolid

        Behavior on x {
            NumberAnimation {
                duration: Theme.animFast
                easing.type: Theme.easing
            }
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
