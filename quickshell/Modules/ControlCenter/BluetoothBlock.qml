import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Bluetooth tile and (when expanded) its device list. See WifiBlock.
ColumnLayout {
    id: root

    required property var cc
    property bool list: true

    visible: BluetoothState.available
    spacing: 0

    Tile {
        Layout.fillWidth: true
        glyph: BluetoothState.icon
        title: "Bluetooth"
        subtitle: BluetoothState.label
        checked: BluetoothState.enabled
        expandable: true
        expanded: root.cc.detail === "bluetooth"
        fuse: root.list
        onToggled: BluetoothState.setEnabled(!BluetoothState.enabled)
        onExpand: root.cc.toggleDetail("bluetooth")
    }

    Loader {
        Layout.fillWidth: true
        active: root.list && root.cc.detail === "bluetooth"
        visible: active
        sourceComponent: BluetoothList {}
    }
}
