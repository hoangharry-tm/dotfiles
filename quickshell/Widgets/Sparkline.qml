import QtQuick
import qs.Common

// A tiny filled line chart. `values` is a list of numbers; scaled to
// `maxValue` (0 = auto-fit to the data).
Canvas {
    id: root

    property var values: []
    property real maxValue: 1
    property color color: Theme.textMuted

    implicitWidth: Theme.sparkWidth
    implicitHeight: Theme.sparkHeight
    antialiasing: true

    // Sparklines live in hover tooltips: skip repainting while hidden
    // (samples keep arriving) and catch up once shown.
    onVisibleChanged: if (visible)
        requestPaint()
    onValuesChanged: if (visible)
        requestPaint()
    onColorChanged: if (visible)
        requestPaint()
    onWidthChanged: if (visible)
        requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        const v = values.map(x => Number.isFinite(x) ? x : 0);
        if (v.length < 2)
            return;
        const top = maxValue > 0 ? maxValue : Math.max(1e-9, ...v);
        const step = width / (v.length - 1);
        const y = i => height - 2 - Math.min(1, v[i] / top) * (height - 4);

        ctx.beginPath();
        ctx.moveTo(0, y(0));
        for (let i = 1; i < v.length; i++)
            ctx.lineTo(i * step, y(i));
        ctx.strokeStyle = color;
        ctx.lineWidth = 1.5;
        ctx.lineJoin = "round";
        ctx.stroke();

        ctx.lineTo(width, height);
        ctx.lineTo(0, height);
        ctx.closePath();
        ctx.fillStyle = Qt.alpha(color, Theme.chartFill);
        ctx.fill();
    }
}
