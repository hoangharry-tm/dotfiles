import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// A grouped card inside the Control Center. `recessed` makes it a child
// surface one level below its parent (inset). `flat` = the L2 disclosure well
// of a Module row inside a Group (DESIGN.md "Hierarchy"): recessed, padding
// `spaceMd` (= padControl, so content lands on the rows' column A).
Surface {
    property bool recessed: false
    property bool flat: false
    property int pad: flat ? Theme.spaceMd : Theme.padCard
    variant: recessed || flat ? "recessed" : "rest"

    default property alias content: column.data
    property alias spacing: column.spacing

    implicitHeight: column.implicitHeight + pad * 2
    radius: Theme.radiusMd

    ColumnLayout {
        id: column

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: pad
        spacing: Theme.gapStack
    }
}
