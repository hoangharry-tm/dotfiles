pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CPU, memory and temperature from /proc and /sys (no helper daemon).
Singleton {
    id: root

    property real cpu: 0            // 0..1
    property real memUsed: 0        // GiB
    property real memTotal: 0       // GiB
    property real temp: 0           // °C
    readonly property real mem: memTotal > 0 ? memUsed / memTotal : 0

    // Network throughput in bytes/s, summed over real interfaces.
    property real netDown: 0
    property real netUp: 0

    // Rolling history for sparklines (HISTORY samples ≈ one minute).
    readonly property int historyLength: 30
    property var cpuHistory: []
    property var memHistory: []
    property var netDownHistory: []
    property var netUpHistory: []

    property var _last: null
    property var _net: null

    function _push(list, value) {
        const next = list.concat([value]);
        return next.length > historyLength ? next.slice(next.length - historyLength) : next;
    }

    function formatRate(bytes) {
        const units = ["B/s", "KB/s", "MB/s", "GB/s"];
        let i = 0;
        while (bytes >= 1024 && i < units.length - 1) {
            bytes /= 1024;
            i++;
        }
        return (i === 0 ? Math.round(bytes) : bytes.toFixed(bytes < 10 ? 1 : 0)) + " " + units[i];
    }

    function sample() {
        stat.reload();
        meminfo.reload();
        thermal.reload();
        netdev.reload();

        const fields = stat.text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
        const idle = fields[3] + fields[4];
        const total = fields.reduce((a, b) => a + b, 0);
        if (_last) {
            const dt = total - _last.total;
            cpu = dt > 0 ? 1 - (idle - _last.idle) / dt : 0;
        }
        _last = { idle, total };

        const kb = key => parseInt((meminfo.text().match(new RegExp("^" + key + ":\\s+(\\d+)", "m")) || [0, 0])[1]);
        memTotal = kb("MemTotal") / 1048576;
        memUsed = (kb("MemTotal") - kb("MemAvailable")) / 1048576;

        const t = parseInt(thermal.text());
        if (t > 0)
            temp = t / 1000;

        // /proc/net/dev: "iface: rx_bytes … (8 fields) tx_bytes …"; skip loopback
        // and virtual bridges so container traffic doesn't double count.
        let rx = 0, tx = 0;
        for (const line of netdev.text().split("\n").slice(2)) {
            const [name, rest] = line.split(":");
            if (!rest || /^\s*(lo|docker|veth|br-|virbr)/.test(name))
                continue;
            const f = rest.trim().split(/\s+/).map(Number);
            rx += f[0];
            tx += f[8];
        }
        const now = Date.now();
        if (_net) {
            const dt = (now - _net.t) / 1000;
            netDown = Math.max(0, (rx - _net.rx) / dt);
            netUp = Math.max(0, (tx - _net.tx) / dt);
        }
        _net = { rx, tx, t: now };

        cpuHistory = _push(cpuHistory, cpu);
        memHistory = _push(memHistory, mem);
        netDownHistory = _push(netDownHistory, netDown);
        netUpHistory = _push(netUpHistory, netUp);
    }

    FileView {
        id: stat

        path: "/proc/stat"
        blockLoading: true
    }

    FileView {
        id: netdev

        path: "/proc/net/dev"
        blockLoading: true
    }

    FileView {
        id: meminfo

        path: "/proc/meminfo"
        blockLoading: true
    }

    // CPU package sensor: x86_pkg_temp (Intel) or k10temp-backed zone (AMD).
    // Zone numbers differ per machine, so find it by type once at startup.
    FileView {
        id: thermal

        path: "/sys/class/thermal/thermal_zone0/temp"
        blockLoading: true
    }

    Process {
        running: true
        command: ["sh", "-c", "for z in /sys/class/thermal/thermal_zone*; do case $(cat $z/type) in x86_pkg_temp|k10temp|cpu*) echo $z/temp; exit;; esac; done"]
        stdout: StdioCollector {
            onStreamFinished: if (text.trim())
                thermal.path = text.trim()
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.sample()
    }
}
