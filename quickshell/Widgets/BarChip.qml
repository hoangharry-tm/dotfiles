import QtQuick
import QtQuick.Layouts
import qs.Common

// A bar item: one hit target on the bar's rhythm (height = Theme.control,
// padding = Theme.padControl, square when it holds a single icon). Put
// content inside; it is centered and spaced by `spacing`.
Clickable {
    id: root

    default property alias content: row.data
    property alias spacing: row.spacing

    // Responsive hooks (see ResponsiveRow): the section's collapse level, and
    // this chip's width at any level, computed from content metrics rather
    // than the laid-out size. `wanted` is the data-driven presence; a width of
    // 0 at the current level hides the chip.
    property int level: 0
    property bool wanted: true
    property var widthAt: l => implicitWidth
    // A chip's width for a given content width (same formula as implicitWidth).
    function chipWidth(content) {
        return Math.max(Theme.control, content + Theme.padControl * 2);
    }

    visible: wanted && widthAt(level) > 0

    radius: Theme.radiusSm
    implicitHeight: Theme.control
    implicitWidth: Math.max(Theme.control, row.implicitWidth + Theme.padControl * 2)

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: Theme.gapInline
    }
}
