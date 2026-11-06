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
    readonly property real strength: active?.signalStrength ?? 0

    readonly property string label: wiredConnected ? "Ethernet" : active ? active.name : wifiEnabled ? "Not connected" : "Off"
    readonly property string icon: wiredConnected ? "󰈀" : !wifiEnabled ? "󰤮" : !active ? "󰤯" : signalIcon(strength)

    function signalIcon(s) {
        return s > 0.75 ? "󰤨" : s > 0.5 ? "󰤥" : s > 0.25 ? "󰤢" : "󰤟";
    }

    function secured(network) {
        return network.security !== WifiSecurityType.Open;
    }

    function setWifi(on) {
        Networking.wifiEnabled = on;
    }

    // Scan only while a network list is on screen.
    function setScanning(on) {
        if (wifi)
            wifi.scannerEnabled = on;
    }
}
