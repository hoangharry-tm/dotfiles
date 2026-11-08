pragma Singleton

import QtQuick
import Quickshell
import qs.Services

// State -> Material Symbols name for the Control Center. Services still return
// Nerd codepoints (the bar uses them); the CC maps its own state here, once.
Singleton {
    function wifi() {
        if (Network.wiredConnected)
            return "lan";
        if (!Network.wifiEnabled || !Network.active)
            return "wifi_off";
        return signal(Network.strength);
    }

    // Wi-Fi signal strength (0..1) -> bars.
    function signal(s) {
        return s > 0.66 ? "wifi" : s > 0.33 ? "wifi_2_bar" : "wifi_1_bar";
    }

    // Bluetooth device class (BlueZ icon name) -> symbol.
    function btDevice(device) {
        const i = device.icon || "";
        return i.includes("headset") || i.includes("headphone") ? "headphones" : i.includes("audio") ? "speaker" : i.includes("mouse") ? "mouse" : i.includes("keyboard") ? "keyboard" : i.includes("phone") ? "smartphone" : i.includes("game") ? "sports_esports" : "bluetooth";
    }

    function bluetooth() {
        return !BluetoothState.enabled ? "bluetooth_disabled" : BluetoothState.connected.length ? "bluetooth_connected" : "bluetooth";
    }

    function volume() {
        return Audio.muted ? "volume_off" : Audio.volume < 0.01 ? "volume_mute" : Audio.volume < 0.5 ? "volume_down" : "volume_up";
    }

    function mic() {
        return Audio.micMuted ? "mic_off" : "mic";
    }

    function battery() {
        if (Power.charging)
            return "battery_charging_full";
        if (Power.percent >= 0.95)
            return "battery_full";
        return "battery_" + Math.max(0, Math.min(6, Math.floor(Power.percent * 7))) + "_bar";
    }

    // WMO weather code -> symbol (same buckets as Weather.iconFor).
    function weather() {
        const c = Weather.code, day = Weather.isDay;
        return c === 0 ? (day ? "clear_day" : "clear_night") : c <= 2 ? (day ? "partly_cloudy_day" : "partly_cloudy_night") : c === 3 ? "cloud" : c <= 48 ? "foggy" : c <= 67 ? "rainy" : c <= 77 ? "weather_snowy" : c <= 82 ? "rainy" : c <= 86 ? "weather_snowy" : "thunderstorm";
    }

    function device(d) {
        return d.type === "desktop" ? "desktop_windows" : d.type === "laptop" ? "laptop_mac" : d.type === "tablet" ? "tablet_mac" : "smartphone";
    }
}
