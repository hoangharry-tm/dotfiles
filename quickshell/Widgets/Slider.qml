import QtQuick
import qs.Common

// Large pill slider, iOS style: a clear glass track with a bright frosted
// fill that carries the icon in dark ink (tap it to mute); drag or scroll anywhere else to set the value.
Item {
    id: root

    property real value: 0               // 0..1
    property string glyph: ""
    property bool dimmed: false          // e.g. muted
    property string trailing: Math.round(shown * 100) + "%"

    signal moved(real value)
    signal iconClicked

    // While dragging (and briefly after) show the local value: the system
    // round-trip (PipeWire/sysfs) lags and would make the fill fight the
    // pointer. External changes (keys, OSD) animate in when idle.
    property real local: 0
    readonly property bool engaged: drag.pressed || settle.running
    readonly property real shown: engaged ? local : value

    // Fill is at least a full circle so the icon always sits on it.
    readonly property real fillWidth: Math.max(height, width * shown)

    implicitHeight: Theme.sliderHeight

    GlassSurface {
        anchors.fill: parent
        radius: Theme.radiusFull

        GlassSurface {
            width: root.fillWidth
            height: parent.height
            radius: Theme.radiusFull
            on: !root.dimmed
            pressed: drag.pressed

            Behavior on width {
                enabled: !root.engaged
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Theme.easing
                }
            }

        }
    }

    Timer {
        id: settle

        interval: 400 // time for the system value to catch up after release
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
        onReleased: settle.restart()
        onWheel: w => commit(root.shown + (w.angleDelta.y > 0 ? 0.05 : -0.05))

        function update(x) {
            commit(x / root.width);
        }

        function commit(v) {
            root.local = Math.max(0, Math.min(1, v));
            settle.restart();
            root.moved(root.local);
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
            color: root.dimmed ? Theme.textMuted : Theme.onGlass
        }
    }

    Label {
        id: readout

        anchors.right: parent.right
        anchors.rightMargin: Theme.spaceMd
        anchors.verticalCenter: parent.verticalCenter
        text: root.trailing
        // Dark ink once the fill reaches the readout.
        color: root.fillWidth > readout.x ? Theme.onGlassMuted : Theme.textMuted
        font.pixelSize: Theme.textXs
        font.family: Theme.mono
    }
}
