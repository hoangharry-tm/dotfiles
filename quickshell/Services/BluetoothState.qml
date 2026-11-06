pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Bluetooth adapter and devices (BlueZ via Quickshell.Bluetooth).
// Named BluetoothState so it doesn't shadow Quickshell's Bluetooth singleton.
Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool scanning: adapter?.discovering ?? false

    readonly property var devices: adapter ? adapter.devices.values.slice().sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || nameOf(a).localeCompare(nameOf(b))) : []
    readonly property var connected: devices.filter(d => d.connected)

    readonly property string label: !enabled ? "Off" : connected.length === 1 ? nameOf(connected[0]) : connected.length > 1 ? connected.length + " devices" : "On"
    readonly property string icon: !enabled ? "󰂲" : connected.length ? "󰂱" : "󰂯"

    function nameOf(device) {
        return device.name || device.deviceName || device.address;
    }

    function setEnabled(on) {
        if (adapter)
            adapter.enabled = on;
    }

    function setScanning(on) {
        if (adapter && adapter.enabled)
            adapter.discovering = on;
    }

    // One tap: disconnect, connect, or pair-then-connect.
    function activate(device) {
        if (device.connected) {
            device.disconnect();
        } else if (device.paired) {
            device.connect();
        } else {
            device.trusted = true;
            device.pair();
        }
    }

    function deviceIcon(device) {
        const i = device.icon || "";
        return i.includes("headset") || i.includes("headphone") ? "󰋋" : i.includes("audio") ? "󰓃" : i.includes("mouse") ? "󰍽" : i.includes("keyboard") ? "󰌌" : i.includes("phone") ? "󰏲" : i.includes("game") ? "󰊴" : "󰂯";
    }
}
