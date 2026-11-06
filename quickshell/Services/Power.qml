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

    readonly property string icon: {
        if (charging)
            return "󰂄";
        const icons = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
        return icons[Math.round(percent * 10)];
    }

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
