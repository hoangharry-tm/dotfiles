import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

// Pulsing red dot and elapsed time while recording; click to stop.
BarChip {
    id: root

    visible: Recorder.recording
    onClicked: Recorder.stop()

    Rectangle {
        implicitWidth: Theme.spaceSm
        implicitHeight: Theme.spaceSm
        radius: Theme.radiusFull
        color: Theme.error

        // Runs only while the chip is visible, so idle cost stays zero.
        SequentialAnimation on opacity {
            running: root.visible
            loops: Animation.Infinite
            NumberAnimation { to: 0.35; duration: Theme.animPulse; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1; duration: Theme.animPulse; easing.type: Easing.InOutSine }
        }
    }

    Label {
        text: Recorder.elapsedLabel
        font.pixelSize: Theme.textSm
        font.features: { "tnum": 1 }
    }
}
