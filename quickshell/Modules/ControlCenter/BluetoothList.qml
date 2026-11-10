import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.Services
import qs.Widgets

// Paired devices (and new ones while scanning). Tap to connect, disconnect
// or pair. Right-click to forget.
DetailList {
    id: root

    title: "Bluetooth"
    actionGlyph: "refresh"
    actionActive: BluetoothState.scanning
    actionTip: BluetoothState.scanning ? "Scanning, " + BluetoothState.scanMinutesLeft + " min left. Click to stop" : "Refresh"
    count: devices.length
    emptyText: BluetoothState.enabled ? (BluetoothState.scanning ? "Searching for devices…" : "No devices") : "Bluetooth is off"
    onAction: BluetoothState.scanning ? BluetoothState.stopScan() : BluetoothState.scanFor(Settings.scanWindow * 1000)

    readonly property var devices: BluetoothState.shown.slice(0, 10)

    ListBlock {
        count: root.devices.length

        Repeater {
            model: root.devices

            ListRow {
                required property var modelData

                Layout.fillWidth: true
                glyph: BluetoothState.deviceIcon(modelData)
                title: BluetoothState.nameOf(modelData)
                subtitle: !modelData.paired ? "Tap to pair" : modelData.connected ? "Connected" : "Paired" // a link without a bond carries no input
                meta: modelData.connected && modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%" : ""
                marked: modelData.connected && modelData.paired
                busy: modelData.pairing || modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting
                onClicked: BluetoothState.activate(modelData)
                onRightClicked: if (modelData.paired)
                    modelData.forget()
            }
        }
    }
}
