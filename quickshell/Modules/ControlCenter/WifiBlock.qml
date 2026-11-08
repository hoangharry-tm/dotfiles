import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Wi-Fi tile and (when expanded) its network list, a separate group below.
// `list: false` leaves the list to the layout (it can span several columns).
ColumnLayout {
    id: root

    required property var cc
    property bool list: true

    spacing: Theme.gapStack

    Tile {
        Layout.fillWidth: true
        glyph: Network.icon
        title: Network.wiredConnected ? "Ethernet" : "Wi-Fi"
        subtitle: Network.label
        checked: Network.wifiEnabled || Network.wiredConnected
        expandable: Network.wifi !== null
        expanded: root.cc.detail === "wifi"
        fuse: false
        onToggled: Network.setWifi(!Network.wifiEnabled)
        onExpand: root.cc.toggleDetail("wifi")
    }

    Loader {
        Layout.fillWidth: true
        active: root.list && root.cc.detail === "wifi"
        visible: active
        sourceComponent: WifiList {}
    }
}
