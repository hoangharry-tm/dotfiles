import QtQuick
import qs.Common

// Large pill slider, macOS style: the accent fill carries the icon (tap it
// to mute); drag or scroll anywhere else to set the value.
Item {
    id: root

    property real value: 0               // 0..1
    property string glyph: ""
    property bool dimmed: false          // e.g. muted
    property color trackColor: Theme.tile // pass a stronger fill when sitting on a card
    property string trailing: Math.round(value * 100) + "%"

    signal moved(real value)
    signal iconClicked

    // Fill is at least a full circle so the icon always sits on it.
    readonly property real fillWidth: Math.max(height, width * value)
    readonly property bool iconCovered: fillWidth >= height

    implicitHeight: Theme.sliderHeight

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusFull
        color: root.trackColor

        Rectangle {
            width: root.fillWidth
            height: parent.height
            radius: Theme.radiusFull
            color: root.dimmed ? Theme.pressed : drag.pressed ? Theme.primaryPressed : Theme.primary

            Behavior on width {
                enabled: !drag.pressed
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Theme.easing
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.anim
                }
            }
        }
    }

    MouseArea {
        id: drag

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        preventStealing: true
        onPressed: m => update(m.x)
        onPositionChanged: m => {
            if (pressed)
                update(m.x);
        }
        onWheel: w => root.moved(Math.max(0, Math.min(1, root.value + (w.angleDelta.y > 0 ? 0.05 : -0.05))))

        function update(x) {
            root.moved(Math.max(0, Math.min(1, x / root.width)));
        }
    }

    // Icon button on top of the drag area (it sits inside the fill's end cap).
    MouseArea {
        width: root.height
        height: root.height
        cursorShape: Qt.PointingHandCursor
        onClicked: root.iconClicked()

        Icon {
            anchors.centerIn: parent
            glyph: root.glyph
            size: Theme.iconLg
            color: root.dimmed ? Theme.textMuted : root.iconCovered ? Theme.primaryText : Theme.text
        }
    }

    Label {
        anchors.right: parent.right
        anchors.rightMargin: Theme.spaceMd
        anchors.verticalCenter: parent.verticalCenter
        text: root.trailing
        color: root.fillWidth > root.width - Theme.rowHeightTall ? Theme.primaryTextMuted : Theme.textMuted
        font.pixelSize: Theme.textXs
        font.family: Theme.mono
    }
}
