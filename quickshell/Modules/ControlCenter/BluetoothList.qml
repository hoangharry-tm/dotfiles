import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.Common
import qs.Services
import qs.Widgets

// Paired devices (and new ones while scanning). Tap to connect, disconnect
// or pair. Right-click to forget.
DetailList {
    id: root

    attached: true
    title: "Bluetooth"
    actionGlyph: "󰑓"
    actionActive: BluetoothState.scanning
    count: devices.length
    emptyText: BluetoothState.enabled ? "Searching for devices…" : "Bluetooth is off"
    onAction: BluetoothState.setScanning(!BluetoothState.scanning)

    // Unnamed new devices are noise; show them only once they have a name.
    readonly property var devices: BluetoothState.devices.filter(d => d.paired || d.connected || d.name).slice(0, 10)

    Repeater {
        model: root.devices

        ListRow {
            required property var modelData

            Layout.fillWidth: true
            glyph: BluetoothState.deviceIcon(modelData)
            title: BluetoothState.nameOf(modelData)
            subtitle: modelData.connected ? "Connected" + (modelData.batteryAvailable ? " · " + Math.round(modelData.battery * 100) + "%" : "") : modelData.paired ? "Paired" : "Tap to pair"
            trailingGlyph: modelData.connected ? "󰄬" : ""
            selected: modelData.connected
            busy: modelData.pairing || modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting
            onClicked: BluetoothState.activate(modelData)
            onRightClicked: if (modelData.paired)
                modelData.forget()
        }
    }
}
