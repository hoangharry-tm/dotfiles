pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

// Wi-Fi and Ethernet via NetworkManager (Quickshell.Networking).
Singleton {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property var wifi: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wired: devices.find(d => d.type === DeviceType.Wired) ?? null

    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wiredConnected: wired?.connected ?? false
    readonly property var networks: wifi ? wifi.networks.values.slice().sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength)) : []
    readonly property var active: networks.find(n => n.connected) ?? null
    // signalStrength can be undefined while NetworkManager is still scanning.
    readonly property real strength: (active && active.signalStrength) || 0

    readonly property string label: wiredConnected ? "Ethernet" : active ? active.name : wifiEnabled ? "Not connected" : "Off"
    readonly property string icon: wiredConnected ? "lan" : !wifiEnabled || !active ? "wifi_off" : signalIcon(strength)

    function signalIcon(s) {
        return s > 0.66 ? "wifi" : s > 0.33 ? "wifi_2_bar" : "wifi_1_bar";
    }

    function secured(network) {
        return network.security !== WifiSecurityType.Open;
    }

    function setWifi(on) {
        Networking.wifiEnabled = on;
    }

    // Scans are explicit and bounded (see ScanWindow): the dropdown shows
    // NetworkManager's cached list until the user asks to refresh.
    readonly property bool scanning: scan.active
    readonly property int scanMinutesLeft: scan.minutesLeft

    function scanFor(ms) {
        if (wifi && wifiEnabled)
            scan.start(ms);
    }

    function stopScan() {
        scan.stop();
    }

    ScanWindow {
        id: scan

        onBegin: if (root.wifi)
            root.wifi.scannerEnabled = true
        onEnd: if (root.wifi)
            root.wifi.scannerEnabled = false
    }
}
