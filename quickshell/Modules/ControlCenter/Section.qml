import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// A grouped card inside the Control Center. `recessed` makes it a child
// surface one level below its parent (inset); `attached` flattens the top
// corners so it fuses with the tile above it.
Surface {
    property int pad: Theme.padCard
    variant: recessed ? "recessed" : "rest"
    property bool recessed: false
    property bool attached: false

    default property alias content: column.data
    property alias spacing: column.spacing

    implicitHeight: column.implicitHeight + pad * 2
    radius: Theme.radiusMd
    topLeftRadius: attached ? 0 : radius
    topRightRadius: attached ? 0 : radius

    ColumnLayout {
        id: column

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: pad
        spacing: Theme.gapStack
    }
}
