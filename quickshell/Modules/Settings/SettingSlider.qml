import QtQuick
import qs.Common
import qs.Widgets

// Widgets/Slider mapped onto a real range: `current` in [from, to], snapped to `step`.
Slider {
    id: root

    property real from: 0
    property real to: 1
    property real step: 1
    property real current: from
    property string suffix: ""

    signal picked(real v)

    width: Theme.panelWidth / 2
    height: Theme.control
    value: (current - from) / (to - from)
    trailing: Math.round(current) + suffix
    onMoved: v => {
        const n = Math.round((from + v * (to - from)) / step) * step;
        if (n !== current)
            picked(n);
    }
}
