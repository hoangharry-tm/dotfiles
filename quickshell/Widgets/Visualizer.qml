import QtQuick
import qs.Common
import qs.Services

// Rounded spectrum bars driven by Cava. Holds Cava only while shown, so the
// cava process exists only when something visible needs it.
Item {
    id: root

    property color color: Theme.primary
    property int barWidth: Theme.spaceXs
    property int barGap: Theme.spaceXs / 2
    readonly property bool live: visible && Media.playing

    implicitWidth: Cava.bars.length * barWidth + (Cava.bars.length - 1) * barGap
    implicitHeight: Theme.icon

    onLiveChanged: live ? Cava.hold() : Cava.release()
    Component.onCompleted: if (live)
        Cava.hold()
    Component.onDestruction: if (live)
        Cava.release()

    Repeater {
        model: Cava.bars.length

        Rectangle {
            required property int index

            x: index * (root.barWidth + root.barGap)
            width: root.barWidth
            // min height keeps a dotted baseline, so the shape reads at silence
            height: Math.max(root.barWidth, root.height * (Cava.bars[index] ?? 0))
            anchors.bottom: parent.bottom
            radius: Theme.radiusFull
            color: root.color
        }
    }
}
