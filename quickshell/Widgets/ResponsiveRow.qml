import QtQuick
import QtQuick.Layouts

// A bar section that never exceeds `available`. Children expose the same
// three members (BarChip has them all): `level` (bound to this row's level),
// `wanted` (data says it should exist) and `widthAt(l)` (its width at
// collapse level l, 0 = hidden). The row picks the lowest level whose summed
// widths fit. Widths come from content metrics, never from laid-out sizes, so
// there is no feedback loop; it re-evaluates only when a width input changes.
RowLayout {
    id: root

    property real available: 0
    property int levels: 1                 // number of collapse levels

    function totalAt(l) {
        let sum = 0, n = 0;
        for (const c of root.children) {
            if (typeof c.widthAt !== "function" || !c.wanted)
                continue;
            const w = c.widthAt(l);
            if (w > 0) {
                sum += w;
                n++;
            }
        }
        return sum + Math.max(0, n - 1) * spacing;
    }

    // Width when fully collapsed: the clock uses it to decide its own level.
    readonly property real minTotal: totalAt(levels - 1)
    readonly property int level: {
        for (let l = 0; l < levels - 1; l++)
            if (totalAt(l) <= available)
                return l;
        return levels - 1;
    }
}
