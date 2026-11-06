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

    radius: Theme.radiusSm
    implicitHeight: Theme.control
    implicitWidth: Math.max(Theme.control, row.implicitWidth + Theme.padControl * 2)

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: Theme.gapInline
    }
}
