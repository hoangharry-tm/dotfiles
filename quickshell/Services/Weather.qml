pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Open-Meteo forecast (no key). The cache file is served instantly at
// startup, then refreshed at most every 15 min while online; failures back
// off exponentially (2 min doubling, capped at 15 min). Offline = no timer
// work, and a refresh runs once connectivity returns if the data is stale.
Singleton {
    id: root

    readonly property int refreshMs: 15 * 60 * 1000
    readonly property int backoffMinMs: 2 * 60 * 1000
    readonly property string cachePath: (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache") + "/quickshell/weather.json"

    // Network.qml exposes no single "online" flag; either link counts.
    readonly property bool online: Network.wiredConnected || Network.active !== null

    // --- Parsed state ------------------------------------------------------
    property bool ready: false
    property real fetchedAt: 0
    property real temp: 0
    property real feels: 0
    property int code: 0
    property bool isDay: true
    property real humidity: 0
    property real wind: 0                // km/h
    property var hourly: []              // [{ time: Date, temp, code }] next 12 h
    property var daily: []               // [{ date: Date, code, max, min }] 5 days
    property string sunrise: ""          // "HH:mm" today
    property string sunset: ""
    readonly property string city: Location.city

    readonly property string glyph: iconFor(code, isDay)
    readonly property string label: labelFor(code)
    readonly property string tempText: ready ? Math.round(temp) + "°" : "--"

    // WMO weather code -> Material Design weather glyph (Nerd Font) + label.
    function iconFor(c, day) {
        const g = c === 0 ? (day ? 0xF0599 : 0xF0594) : c <= 2 ? (day ? 0xF0595 : 0xF0F31) : c === 3 ? 0xF0590 : c <= 48 ? 0xF0591 : c <= 57 ? 0xF0597 : c <= 65 ? 0xF0597 : c <= 67 ? 0xF067F : c <= 77 ? 0xF0598 : c <= 82 ? 0xF0596 : c <= 86 ? 0xF0598 : c === 95 ? 0xF067E : 0xF067F;
        return String.fromCodePoint(g);
    }

    function labelFor(c) {
        const m = {
            0: "Clear",
            1: "Mostly clear",
            2: "Partly cloudy",
            3: "Overcast",
            45: "Fog",
            48: "Rime fog",
            51: "Light drizzle",
            53: "Drizzle",
            55: "Heavy drizzle",
            56: "Freezing drizzle",
            57: "Freezing drizzle",
            61: "Light rain",
            63: "Rain",
            65: "Heavy rain",
            66: "Freezing rain",
            67: "Freezing rain",
            71: "Light snow",
            73: "Snow",
            75: "Heavy snow",
            77: "Snow grains",
            80: "Showers",
            81: "Showers",
            82: "Heavy showers",
            85: "Snow showers",
            86: "Snow showers",
            95: "Thunderstorm",
            96: "Thunderstorm, hail",
            99: "Thunderstorm, hail"
        };
        return m[c] ?? "Unknown";
    }

    function apply(d) {
        const c = d.current, h = d.hourly, y = d.daily;
        temp = c.temperature_2m;
        feels = c.apparent_temperature;
        code = c.weather_code;
        isDay = c.is_day === 1;
        humidity = c.relative_humidity_2m;
        wind = c.wind_speed_10m;
        hourly = h.time.slice(0, 12).map((t, i) => ({
                    time: new Date(t),
                    temp: h.temperature_2m[i],
                    code: h.weather_code[i]
                }));
        daily = y.time.slice(0, 5).map((t, i) => ({
                    date: new Date(t + "T00:00"),
                    code: y.weather_code[i],
                    max: y.temperature_2m_max[i],
                    min: y.temperature_2m_min[i]
                }));
        sunrise = (y.sunrise[0] || "").slice(11, 16);
        sunset = (y.sunset[0] || "").slice(11, 16);
        ready = true;
    }

    readonly property string url: "https://api.open-meteo.com/v1/forecast?latitude=" + Location.latitude + "&longitude=" + Location.longitude + "&timezone=" + encodeURIComponent(Location.timezone) + "&current=temperature_2m,apparent_temperature,weather_code,relative_humidity_2m,wind_speed_10m,is_day" + "&hourly=temperature_2m,weather_code&forecast_hours=12" + "&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset&forecast_days=5"

    property int failures: 0
    readonly property bool stale: Date.now() - fetchedAt >= refreshMs

    function refresh() {
        if (online && !fetcher.running)
            fetcher.running = true;
    }

    // One-shot timer re-armed after every attempt; interval = next delay.
    Timer {
        id: next

        interval: root.failures === 0 ? root.refreshMs : Math.min(root.refreshMs, root.backoffMinMs * Math.pow(2, root.failures - 1))
        running: root.online
        onTriggered: root.refresh()
    }

    // Back online (or location changed): fetch now if the data is stale.
    onOnlineChanged: if (online && stale)
        refresh()
    onUrlChanged: if (ready)
        fetchedAt = 0

    Process {
        id: fetcher

        command: ["curl", "-sf", "--max-time", "20", root.url]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    root.apply(d);
                    root.fetchedAt = Date.now();
                    root.failures = 0;
                    cache.setText(JSON.stringify({
                        fetchedAt: root.fetchedAt,
                        url: root.url,
                        data: d
                    }));
                } catch (e) {
                    root.failures++;
                }
                next.restart();
            }
        }
    }

    FileView {
        id: cache

        path: root.cachePath
        blockLoading: true
        printErrors: false
        atomicWrites: true
        onLoaded: {
            try {
                const c = JSON.parse(text());
                if (c.url !== root.url)
                    return; // other location: ignore
                root.apply(c.data);
                root.fetchedAt = c.fetchedAt;
            } catch (e) {}
        }
        onLoadFailed: root.refresh()
    }

    // Cache was missing/stale at startup: fetch once the network settles.
    Component.onCompleted: Qt.callLater(() => {
        if (stale)
            refresh();
    })
}
