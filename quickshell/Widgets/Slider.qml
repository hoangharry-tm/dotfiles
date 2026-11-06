import QtQuick
import qs.Common

// Thin-track slider with a leading icon button (e.g. mute).
Item {
    id: root

    property real value: 0               // 0..1
    property string glyph: ""
    property bool dimmed: false          // e.g. muted
    property string trailing: Math.round(value * 100) + "%"

    signal moved(real value)
    signal iconClicked

    implicitHeight: Theme.control

    Clickable {
        id: iconButton

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.control
        height: Theme.control
        radius: Theme.radiusFull
        onClicked: root.iconClicked()

        Icon {
            anchors.centerIn: parent
            glyph: root.glyph
            size: Theme.icon
            color: root.dimmed ? Theme.textMuted : Theme.text
        }
    }

    Item {
        id: track

        anchors.left: iconButton.right
        anchors.leftMargin: Theme.spaceMd // thumb overhangs the track by thumb/2
        anchors.right: valueLabel.left
        anchors.rightMargin: Theme.spaceMd
        anchors.verticalCenter: parent.verticalCenter
        height: Theme.thumb + Theme.spaceXs

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: Theme.trackHeight
            radius: Theme.trackHeight / 2
            color: Theme.tile

            Rectangle {
                width: Math.max(height, parent.width * root.value)
                height: parent.height
                radius: Theme.trackHeight / 2
                color: root.dimmed ? Theme.textMuted : Theme.primary

                Behavior on width {
                    enabled: !drag.pressed
                    NumberAnimation {
                        duration: Theme.animFast
                    }
                }
            }
        }

        Rectangle {
            x: parent.width * root.value - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.thumb
            height: width
            radius: width / 2
            color: Theme.text

            Behavior on width {
                NumberAnimation {
                    duration: Theme.animFast
                }
            }
        }

        MouseArea {
            id: drag

            anchors.fill: parent
            anchors.margins: -Theme.spaceSm
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            preventStealing: true

            function update(x) {
                root.moved(Math.max(0, Math.min(1, (x - Theme.spaceSm) / track.width)));
            }

            onPressed: m => update(m.x)
            onPositionChanged: m => {
                if (pressed)
                    update(m.x);
            }
            onWheel: w => root.moved(Math.max(0, Math.min(1, root.value + (w.angleDelta.y > 0 ? 0.05 : -0.05))))
        }
    }

    Label {
        id: valueLabel

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.control + Theme.spaceXs
        horizontalAlignment: Text.AlignRight
        text: root.trailing
        color: Theme.textMuted
        font.pixelSize: Theme.textXs
        font.family: Theme.mono
    }
}
