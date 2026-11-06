pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// THE single place for where you are. Used by NightLight (sunset/sunrise)
// and Weather (forecast). The auto/fixed values live in Services/Settings.qml.
//
// Auto-detect (`autoDetect: true`): look the location up by IP (ipinfo.io)
// at shell start, at most once every 6 h, and cache it in
// ~/.cache/quickshell/location.json. The cache is the fallback: when a lookup
// fails (offline, rate-limited) the most recent detected location stays in
// effect. The fixed values below are used only before any lookup succeeded.
Singleton {
    id: root

    readonly property bool autoDetect: Settings.locAutoDetect
    readonly property real fixedLatitude: Settings.locLatitude
    readonly property real fixedLongitude: Settings.locLongitude
    readonly property string fixedCity: Settings.locCity
    readonly property string fixedTimezone: Settings.locTimezone

    // Last successful lookup (from the cache, then refreshed); wins when set.
    property var detected: null
    readonly property bool useDetected: autoDetect && detected !== null

    readonly property real latitude: useDetected ? detected.lat : fixedLatitude
    readonly property real longitude: useDetected ? detected.lon : fixedLongitude
    readonly property string city: useDetected ? detected.city : fixedCity
    readonly property string timezone: useDetected ? detected.tz : fixedTimezone

    readonly property int refreshMs: 6 * 3600 * 1000 // you rarely move faster
    readonly property string cachePath: (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache") + "/quickshell/location.json"

    FileView {
        id: cache

        path: root.autoDetect ? root.cachePath : ""
        // Turning auto-detect on later: the path change reloads the cache,
        // which looks the location up when it is stale or missing.
        printErrors: false
        atomicWrites: true
        onLoaded: {
            try {
                const d = JSON.parse(text());
                if (Number.isFinite(d.lat) && Number.isFinite(d.lon))
                    root.detected = d;
                // Refresh when stale; a failure keeps this cached location.
                if (!(Date.now() - (d.at || 0) < root.refreshMs))
                    lookup.running = true;
            } catch (e) {
                lookup.running = true;
            }
        }
        onLoadFailed: if (root.autoDetect)
            lookup.running = true
    }

    Process {
        id: lookup

        // ipinfo.io: HTTPS, no key; ipapi.co rate-limits (HTTP 429) too eagerly.
        command: ["curl", "-sf", "--max-time", "15", "https://ipinfo.io/json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j = JSON.parse(text);
                    const [lat, lon] = (j.loc || "").split(",").map(Number);
                    if (!Number.isFinite(lat) || !Number.isFinite(lon))
                        return;
                    const d = {
                        lat: lat,
                        lon: lon,
                        city: j.city || root.fixedCity,
                        tz: j.timezone || root.fixedTimezone,
                        at: Date.now()
                    };
                    root.detected = d;
                    cache.setText(JSON.stringify(d));
                } catch (e) {}
            }
        }
    }
}
