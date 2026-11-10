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
    readonly property bool scanning: scan.active
    readonly property int scanMinutesLeft: scan.minutesLeft

    readonly property var devices: adapter ? adapter.devices.values.slice().sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || nameOf(a).localeCompare(nameOf(b))) : []
    // Known devices always; strangers only while scanning, and only if they
    // advertise a real name AND a device type. Nameless ones show as a MAC
    // alias, and typeless named ones are neighbours' IoT (lights, beacons).
    readonly property var shown: devices.filter(d => d.paired || d.connected || (scanning && isPresentable(d)))
    readonly property var connected: devices.filter(d => d.connected)

    readonly property string label: !enabled ? "Off" : connected.length === 1 ? nameOf(connected[0]) : connected.length > 1 ? connected.length + " devices" : "On"
    readonly property string icon: !enabled ? "bluetooth_disabled" : connected.length ? "bluetooth_connected" : "bluetooth"

    function nameOf(device) {
        return device.name || device.deviceName || device.address;
    }

    function isPresentable(device) {
        return !!device.deviceName && !!device.icon && !/^([0-9a-f]{2}[:-]){5}[0-9a-f]{2}$/i.test(device.deviceName);
    }

    function setEnabled(on) {
        if (adapter)
            adapter.enabled = on;
    }

    // Explicit, bounded scan (see ScanWindow); never left running.
    function scanFor(ms) {
        if (adapter && adapter.enabled)
            scan.start(ms);
    }

    function stopScan() {
        scan.stop();
    }

    ScanWindow {
        id: scan

        onBegin: if (root.adapter)
            root.adapter.discovering = true
        onEnd: if (root.adapter)
            root.adapter.discovering = false
    }

    // Radio switched off mid-scan: end the window too.
    onEnabledChanged: if (!enabled)
        scan.stop()

    // Never leave the radio scanning if the shell goes away.
    Component.onDestruction: if (adapter && adapter.discovering)
        adapter.discovering = false

    // One tap: pair-then-connect, disconnect, or connect. Unpaired comes
    // first: a device can be linked but unpaired (a keyboard that lost its
    // bond), and disconnecting it would never get it paired.
    function activate(device) {
        if (!device.paired) {
            device.trusted = true;
            device.pair();
        } else if (device.connected) {
            device.disconnect();
        } else {
            device.connect();
        }
    }

    function deviceIcon(device) {
        const i = device.icon || "";
        return i.includes("headset") || i.includes("headphone") ? "headphones" : i.includes("audio") ? "speaker" : i.includes("mouse") ? "mouse" : i.includes("keyboard") ? "keyboard" : i.includes("phone") ? "smartphone" : i.includes("game") ? "sports_esports" : "bluetooth";
    }
}
