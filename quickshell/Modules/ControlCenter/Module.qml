import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// An expandable module: a summary tile that opens its card right below,
// fused at one edge. Only one module is open at a time (`cc.module`).
ColumnLayout {
    id: root

    required property var cc
    required property string kind       // CcCard kind, also the open-state key
    property string glyph: ""
    property string title: ""
    property string summary: ""
    property bool lit: false             // tile drawn "on"
    readonly property bool open: cc.module === kind

    spacing: 0

    Tile {
        Layout.fillWidth: true
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
        Layout.fillWidth: true
        cc: root.cc
        kind: root.kind
        attach: true
        // wanted && open: the card is built on demand and freed on close
        active: wanted && root.open
        visible: active
    }
}
