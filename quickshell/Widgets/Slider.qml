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

    implicitHeight: 32

    Clickable {
        id: iconButton

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 30
        height: 30
        radius: 15
        onClicked: root.iconClicked()

        Icon {
            anchors.centerIn: parent
            glyph: root.glyph
            size: Theme.iconLg - 2
            color: root.dimmed ? Theme.textMuted : Theme.text
        }
    }

    Item {
        id: track

        anchors.left: iconButton.right
        anchors.leftMargin: 10
        anchors.right: valueLabel.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: 20

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 6
            radius: 3
            color: Theme.tile

            Rectangle {
                width: Math.max(height, parent.width * root.value)
                height: parent.height
                radius: 3
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
            width: drag.pressed || drag.containsMouse ? 16 : 12
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
            anchors.margins: -6
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            preventStealing: true

            function update(x) {
                root.moved(Math.max(0, Math.min(1, (x - 6) / track.width)));
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
        width: 38
        horizontalAlignment: Text.AlignRight
        text: root.trailing
        color: Theme.textMuted
        font.pixelSize: Theme.textSm
        font.family: Theme.mono
    }
}
