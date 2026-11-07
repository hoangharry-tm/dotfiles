pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// Per-battery view (UPower) plus the charge-limit control (`battery-limit`,
// modules/power.nix) and low-battery notices. UPower gives % / state / health
// live; the limit is read from sysfs through the script only on demand
// (refresh() when a panel opens, and after a change), never polled.
Singleton {
    id: root

    // Physical batteries, stable order (BAT0, BAT1). One entry on most laptops.
    readonly property var batteries: UPower.devices.values.filter(d => d.type === UPowerDeviceType.Battery && d.isPresent !== false).map(d => ({
                name: (d.nativePath || "").split("/").pop(),
                percent: d.percentage,
                charging: d.state === UPowerDeviceState.Charging,
                discharging: d.state === UPowerDeviceState.Discharging,
                full: d.state === UPowerDeviceState.FullyCharged,
                health: d.healthSupported ? d.healthPercentage : -1
            })).sort((a, b) => a.name < b.name ? -1 : 1)
    readonly property bool multi: batteries.length > 1

    // Charge limit (empty/unsupported on machines without the sysfs files).
    property var info: ({ supported: false, writable: false, limit: 100, fullOnce: false, batteries: [] })
    readonly property bool limitSupported: info.supported
    readonly property bool limitWritable: info.writable
    readonly property int limit: info.limit
    readonly property bool fullOnce: info.fullOnce
    // What the battery is actually held to right now (100 during "full once").
    readonly property int activeStop: info.batteries.length ? info.batteries[0].stop : 100
    readonly property bool limited: limitSupported && activeStop < 100

    function refresh() {
        if (!status.running)
            status.running = true;
    }

    function setLimit(n) {
        act.command = ["battery-limit", "set", String(n)];
        act.running = true;
    }

    function setFullOnce(on) {
        act.command = ["battery-limit", "full-once", on ? "on" : "off"];
        act.running = true;
    }

    Process {
        id: status

        command: ["battery-limit", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.info = JSON.parse(text);
                } catch (e) {}
            }
        }
    }

    Process {
        id: act

        onRunningChanged: if (!running)
            root.refresh()
    }

    // "Charge to full once" ends on unplug / full (power-watch applies it);
    // re-read so the UI follows.
    Connections {
        target: Power

        function onPluggedChanged() {
            root.refresh();
        }
    }

    // Low-battery notices: 15% and 5%, once per discharge (re-armed on plug-in).
    property int _warned: 0

    function _check() {
        if (!Power.hasBattery || Power.plugged) {
            _warned = 0;
            return;
        }
        const pct = Math.round(Power.percent * 100);
        const level = pct <= 5 ? 5 : pct <= 15 ? 15 : 0;
        if (level && (_warned === 0 || level < _warned)) {
            _warned = level;
            Quickshell.execDetached(["notify-send", "-u", "critical", "-a", "Battery", "-i", level === 5 ? "battery-empty" : "battery-caution", level === 5 ? "Battery critically low" : "Battery low", pct + "% left. Plug in soon."]);
        }
    }

    Connections {
        target: Power

        function onPercentChanged() {
            root._check();
        }
        function onPluggedChanged() {
            root._check();
        }
    }

    Component.onCompleted: {
        refresh();
        _check();
    }
}
