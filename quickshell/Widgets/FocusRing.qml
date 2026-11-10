import QtQuick
import qs.Common

// Keyboard-focus ring for a control (Button, Clickable, Segmented). Shown only
// for keyboard focus (`visualFocus`: Tab/Backtab/shortcut), never on a mouse
// click. Sits just outside the control, so its radius is the control's plus
// the inset (nested radii, DESIGN.md); the same `primaryRing` as other focus.
//   FocusRing { target: root }   // inside the control
Rectangle {
    id: ring

    required property Item target
    property real radiusBase: target?.radius ?? 0
    readonly property int inset: Theme.spaceXs / 2

    anchors.fill: parent
    anchors.margins: -inset
    radius: Math.min(radiusBase, Math.min(width, height) / 2 - inset) + inset
    color: "transparent"
    border.width: inset
    border.color: Theme.primaryRing
    // Item has no visualFocus (only Controls do); Item.focusReason (Qt 6.7+)
    // tells a Tab from a click.
    visible: target ? target.activeFocus && (target.focusReason === Qt.TabFocusReason || target.focusReason === Qt.BacktabFocusReason || target.focusReason === Qt.ShortcutFocusReason) : false
    enabled: false
}
