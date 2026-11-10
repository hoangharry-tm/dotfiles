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

    // Sampling cadence: slow at rest (the chip only needs cpu/mem/temp to
    // decide whether to appear), fast only while the SystemChip card is open.
    // Everything below, plus net, history, sensors, fan and procs, is
    // detail-only: sampled and parsed only while `detailed`.
    property bool detailed: false
    readonly property int restInterval: PowerMode.lowPower ? 30000 : 10000
    readonly property int detailInterval: 2000
    property real uptime: 0         // seconds
    property real load: 0           // 1-minute load average

    // Detail view (card open only): swap, labelled sensors, fan, busiest processes.
    property real swapUsed: 0       // GiB
    property real swapTotal: 0      // GiB
    property var sensors: []        // [{ name, temp }] CPU / Drive / GPU, whichever exist
    property int fanRpm: -1         // -1 = no fan sensor (card hides the row)
    property var procs: []          // [{ pid, name, cpu }] top by CPU; cpu in cores (1 = one full core)
    readonly property int procCount: 5
    // Never offered a kill action: killing these takes the session down.
    readonly property var protectedProcs: ["quickshell", "niri", "systemd", "dbus-daemon", "dbus-broker", "Xwayland", "pipewire", "wireplumber"]
    property var _ticks: null

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

    function formatUptime(seconds) {
        const m = Math.floor(seconds / 60), h = Math.floor(m / 60), d = Math.floor(h / 24);
        return d > 0 ? d + "d " + (h % 24) + "h" : h > 0 ? h + "h " + (m % 60) + "m" : m + "m";
    }

    function sample() {
        stat.reload();
        meminfo.reload();
        thermal.reload();

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

        if (!detailed)
            return;

        netdev.reload();
        uptimeFile.reload();
        loadavg.reload();
        uptime = parseFloat(uptimeFile.text()) || 0;
        load = parseFloat(loadavg.text()) || 0;
        swapTotal = kb("SwapTotal") / 1048576;
        swapUsed = (kb("SwapTotal") - kb("SwapFree")) / 1048576;
        if (!probe.running)
            probe.running = true;

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
        id: uptimeFile

        path: "/proc/uptime"
        blockLoading: true
    }

    FileView {
        id: loadavg

        path: "/proc/loadavg"
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

    // One timer for everything; the interval follows `detailed`/low power and
    // the first tick after a change fires at once. cpu/net rates use real
    // timestamps or tick totals, so they stay correct across intervals.
    Timer {
        interval: root.detailed ? root.detailInterval : root.restInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.sample()
    }

    // Substring match: Nix wraps binaries (".quickshell-wra").
    function canKill(proc) {
        return !protectedProcs.some(n => proc.name.includes(n));
    }

    function kill(proc) {
        if (canKill(proc))
            Quickshell.execDetached(["kill", "-TERM", String(proc.pid)]);
    }

    // hwmon numbering differs per machine: pick sensors by driver name and
    // label, never by number. First match per display name wins.
    readonly property var _wanted: [
        { name: "CPU", hw: /^(coretemp|k10temp|zenpower|cpu_thermal)$/, label: /^(Package|Tctl|Tdie)/ },
        { name: "CPU", hw: /^thinkpad$/, label: /^(CPU|)$/ },
        { name: "Drive", hw: /^nvme$/, label: /^(Composite|)$/ },
        { name: "GPU", hw: /^(amdgpu|radeon|nouveau)$/, label: /^(edge|)$/ }
    ]

    // One `sh` per tick: all hwmon values via one grep, then utime+stime of
    // my own processes from /proc/<pid>/stat via one awk (comm may hold spaces
    // or parens, so split after the last ")").
    readonly property string _awk: '{ s = $0; sub(/^[0-9]+ \\(/, "", s); n = match(s, /\\)[^)]*$/); split(substr(s, n + 2), f, " "); print $1, f[12] + f[13], substr(s, 1, n - 1) }'
    readonly property string _script: "echo '#hw'; grep -H . /sys/class/hwmon/hwmon*/name /sys/class/hwmon/hwmon*/temp*_input /sys/class/hwmon/hwmon*/temp*_label /sys/class/hwmon/hwmon*/fan*_input 2>/dev/null; " + "echo '#ps'; find /proc -maxdepth 1 -name '[0-9]*' -user \"$(id -u)\" -printf '%p/stat\\n' 2>/dev/null | xargs awk '" + _awk + "' 2>/dev/null"

    function _parse(out) {
        const hw = {}, ticks = {};
        let fan = -1, kind = "";
        for (const line of out.split("\n")) {
            if (line === "#hw" || line === "#ps") {
                kind = line;
                continue;
            }
            if (kind === "#hw") {
                const m = line.match(/hwmon(\d+)\/(\w+?)(?:_(input|label))?:(.*)$/);
                if (!m)
                    continue;
                const [, n, key, sub, v] = m;
                hw[n] = hw[n] || { temps: {} };
                if (key === "name")
                    hw[n].name = v;
                else if (/^fan/.test(key) && fan < 0)
                    fan = parseInt(v);
                else if (/^temp/.test(key))
                    (hw[n].temps[key] = hw[n].temps[key] || {})[sub] = v;
            } else {
                const m = line.match(/^(\d+) (\d+) (.*)$/);
                if (m)
                    ticks[m[1]] = { pid: +m[1], t: +m[2], name: m[3] };
            }
        }
        const found = [];
        for (const w of _wanted) {
            if (found.some(f => f.name === w.name))
                continue;
            for (const h of Object.values(hw)) {
                if (!h.name || !w.hw.test(h.name))
                    continue;
                const t = Object.values(h.temps).find(x => w.label.test(x.label || "") && parseInt(x.input) > 0);
                if (t) {
                    found.push({ name: w.name, temp: parseInt(t.input) / 1000 });
                    break;
                }
            }
        }
        sensors = found;
        fanRpm = fan;

        // CLK_TCK is 100 on Linux: Δticks / (100 · Δs) = cores in use.
        const now = Date.now();
        if (_ticks) {
            const dt = (now - _ticks.now) / 1000;
            procs = Object.values(ticks).filter(p => _ticks.map[p.pid] !== undefined).map(p => ({ pid: p.pid, name: p.name, cpu: Math.max(0, (p.t - _ticks.map[p.pid]) / (100 * dt)) })).sort((a, b) => b.cpu - a.cpu).slice(0, procCount);
        }
        const map = {};
        for (const p of Object.values(ticks))
            map[p.pid] = p.t;
        _ticks = { now, map };
    }

    Process {
        id: probe

        command: ["sh", "-c", root._script]
        stdout: StdioCollector {
            onStreamFinished: root._parse(text)
        }
    }

    // Closing the card drops the detail state, so the next open starts clean
    // (the rate and process deltas need one tick before they show).
    onDetailedChanged: {
        _ticks = null;
        _net = null;
        procs = [];
        cpuHistory = [];
        memHistory = [];
        netDownHistory = [];
        netUpHistory = [];
    }
}
