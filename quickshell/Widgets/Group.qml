import QtQuick
import QtQuick.Layouts
import qs.Common

// Grouped list (Gestalt common region, iOS "inset grouped"): related rows
// share ONE rest surface instead of each being its own card, so a group reads
// as a unit and the space between groups (gapSection) reads as intentional.
// Rows inside draw no fill of their own at rest, only a hover/press wash with
// radius `rowRadius` (concentric: radiusMd - inset = radiusSm). Rows are
// separated by space alone (no hairlines inside a sheet). `flush` draws no
// surface: the group sits inside a well that already is the common region
// (DetailList), keeping the same inset and row radius.
Item {
    id: root

    default property alias content: column.data
    property bool flush: false
    property alias spacing: column.spacing
    readonly property int inset: Theme.spaceXs
    readonly property int rowRadius: Theme.radiusMd - inset

    implicitWidth: column.implicitWidth + inset * 2
    implicitHeight: column.implicitHeight + inset * 2
    // A group with nothing to show takes no space. Rows say so with a `present`
    // property (default true); `visible` can't be asked: hiding the group hides
    // its rows too, and it would never come back.
    visible: column.children.some(c => c.present !== false)

    Surface {
        visible: !root.flush
        anchors.fill: parent
        radius: Theme.radiusMd
    }

    ColumnLayout {
        id: column

        anchors.fill: parent
        anchors.margins: root.inset
        spacing: 0
    }
}
