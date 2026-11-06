import QtQuick
import qs.Common

// A circular progress ring: a track plus an accent arc running clockwise from
// 12 o'clock for `value` (0..1). Painted only when an input changes, so a
// once-a-second value costs one small repaint a second and nothing at rest.
Canvas {
    id: root

    property real value: 0
    property int lineWidth: Theme.spaceXs / 2
    property color tone: Theme.primary
    property color track: Theme.outlineVariant

    antialiasing: true

    onValueChanged: requestPaint()
    onToneChanged: requestPaint()
    onTrackChanged: requestPaint()
    onWidthChanged: requestPaint()
    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        const c = width / 2, r = c - lineWidth / 2, top = -Math.PI / 2;
        ctx.lineWidth = lineWidth;
        ctx.lineCap = "round";
        ctx.strokeStyle = track;
        ctx.beginPath();
        ctx.arc(c, c, r, 0, Math.PI * 2);
        ctx.stroke();
        if (value <= 0)
            return;
        ctx.strokeStyle = tone;
        ctx.beginPath();
        ctx.arc(c, c, r, top, top + Math.PI * 2 * Math.min(1, value));
        ctx.stroke();
    }
}
