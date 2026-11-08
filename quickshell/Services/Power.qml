pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Battery (UPower) and power profiles (power-profiles-daemon).
Singleton {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery?.isLaptopBattery ?? false
    readonly property real percent: battery?.percentage ?? 0
    readonly property bool charging: battery?.state === UPowerDeviceState.Charging
    readonly property bool plugged: !UPower.onBattery
    readonly property real secondsLeft: charging ? (battery?.timeToFull ?? 0) : (battery?.timeToEmpty ?? 0)

    // Battery health (full vs design capacity), averaged over the physical
    // batteries (the T480 has two); -1 when UPower can't tell.
    readonly property real health: {
        const bats = UPower.devices.values.filter(d => d.type === UPowerDeviceType.Battery && d.healthSupported);
        return bats.length ? bats.reduce((a, d) => a + d.healthPercentage, 0) / bats.length : -1;
    }
    // Always-on helpers (low-battery notices, ThinkPad LEDs): referencing the
    // singletons here instantiates them, since Power is loaded at startup.
    readonly property var background: [Battery, Leds]
    readonly property real watts: Math.abs(battery?.changeRate ?? 0)

    // Material Symbols name: seven fill levels (0..6) like the bar and the CC.
    readonly property string icon: charging ? "battery_charging_full" : percent >= 0.95 ? "battery_full" : "battery_" + Math.max(0, Math.min(6, Math.floor(percent * 7))) + "_bar"

    readonly property string timeLabel: {
        if (secondsLeft <= 0)
            return plugged ? "Plugged in" : "";
        const h = Math.floor(secondsLeft / 3600);
        const m = Math.round((secondsLeft % 3600) / 60);
        return (h ? h + " h " : "") + m + " min" + (charging ? " to full" : " left");
    }

    // PowerSaver, Balanced, Performance
    readonly property int profile: PowerProfiles.profile
    readonly property bool hasPerformance: PowerProfiles.hasPerformanceProfile

    function setProfile(p) {
        PowerProfiles.profile = p;
    }
}
