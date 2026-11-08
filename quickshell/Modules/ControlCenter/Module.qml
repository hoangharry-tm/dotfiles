import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// An expandable module: a flat row of a Group that opens its card right below
// as an L2 recessed well inside the same group (edges aligned with the row
// wash, radius = rowRadius). The well pads `spaceMd` = padControl, so its
// content starts on the row's column A; `spaceMd` after it keeps the well's
// padding no larger than its distance to the next row. One open at a time.
ColumnLayout {
    id: root

    required property var cc
    required property string kind       // CcCard kind, also the open-state key
    property string glyph: ""
    property string title: ""
    property string summary: ""
    property bool lit: false             // tile drawn "on"
    property real rowRadius: Theme.radiusSm // the group's concentric row radius
    readonly property bool open: cc.module === kind

    spacing: 0
    readonly property bool present: card.wanted // a module with nothing to say takes no space (the Group asks this)
    visible: present

    Tile {
        Layout.fillWidth: true
        flat: true
        rowRadius: root.rowRadius
        glyph: root.glyph
        title: root.title
        subtitle: root.summary
        checked: root.lit
        expandable: true
        expanded: root.open
        onToggled: root.cc.toggleModule(root.kind)
        onExpand: root.cc.toggleModule(root.kind)
    }

    CcCard {
        id: card

        Layout.fillWidth: true
        cc: root.cc
        kind: root.kind
        flat: true
        wellRadius: root.rowRadius
        Layout.bottomMargin: Theme.spaceMd
        // wanted && open: the card is built on demand and freed on close
        active: wanted && root.open
        visible: active
    }
}
