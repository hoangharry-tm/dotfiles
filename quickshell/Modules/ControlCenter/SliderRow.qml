import QtQuick
import qs.Common
import qs.Widgets

// A large slider with an optional chevron that opens a picker.
Item {
    id: root

    property alias value: slider.value
    property alias glyph: slider.glyph
    property alias dimmed: slider.dimmed
    property bool expandable: true
    property bool expanded: false

    signal moved(real value)
    signal iconClicked
    signal expand

    implicitHeight: slider.implicitHeight

    Slider {
        id: slider

        anchors.left: parent.left
        anchors.right: chevron.visible ? chevron.left : parent.right
        anchors.rightMargin: chevron.visible ? Theme.gapInline : 0
        onMoved: v => root.moved(v)
        onIconClicked: root.iconClicked()
    }

    Clickable {
        id: chevron

        visible: root.expandable
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.height
        height: root.height
        radius: Theme.radiusFull
        color: "transparent"
        onClicked: root.expand()

        Surface {
            anchors.fill: parent
            radius: parent.radius
            hovered: parent.hovered
            pressed: parent.pressed || root.expanded
        }

        Icon {
            anchors.centerIn: parent
            glyph: "󰅂"
            color: Theme.textMuted
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
