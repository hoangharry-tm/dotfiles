pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

// Events from ~/.cache/quickshell/calendar.json, written every 10 min by the
// `calendar-sync` user service (modules/calendar.nix; read-only ICS feeds).
// This singleton only reads the cache; it never sees a calendar URL.
//
// No polling: one single-shot timer sleeps until the next boundary (an event
// starting/ending, its reminder, the chip window, midnight) and is capped at
// 10 min so a suspend (monotonic clocks stop) can never hide a boundary for long.
// `now` changes only there, so every binding below re-evaluates only then.
Singleton {
    id: root

    readonly property string cachePath: (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache") + "/quickshell/calendar.json"
    readonly property int maxSleepMs: 10 * 60 * 1000
    readonly property int lineWindowMs: 12 * 3600 * 1000 // desktop line horizon
    readonly property var fallbackColors: [Theme.primary, Theme.tertiary, Theme.secondary]

    property var events: []          // [{id, calendar, title, start, end (ms), allDay, location, link, color, colorIdx}]
    property var calendars: []       // [{name, colorIdx, ok, error}]
    property real syncedAt: 0        // ms; 0 = never
    property real now: Date.now()
    property bool syncing: false

    // Per local day (yyyymmdd): events, allDay first then by start; and up to 3 distinct dot colors.
    readonly property var byDay: index(events)

    readonly property var upcoming: events.filter(e => e.end > now)
    readonly property var today: eventsOn(new Date(now))
    // First timed event that has not ended (running or upcoming), by start.
    readonly property var next: upcoming.find(e => !e.allDay) ?? null
    // Bar chip: what starts within the chip window beats a long-running event.
    readonly property var chipEvent: {
        const timed = upcoming.filter(e => !e.allDay);
        const soon = timed.find(e => e.start > now && e.start - now <= Settings.calendarChipMin * 60000);
        return soon ?? timed.find(e => e.start <= now) ?? null;
    }
    // Desktop line: "Next: Standup 10:00", empty when nothing is within 12 h.
    readonly property string line: {
        const e = next;
        if (!e)
            return "";
        if (e.start <= now)
            return "Now: " + e.title + " until " + fmtTime(e.end);
        return e.start - now <= lineWindowMs ? "Next: " + e.title + " " + fmtTime(e.start) : "";
    }

    function fmtTime(ms) {
        return Qt.formatDateTime(new Date(ms), Settings.clock24h ? "HH:mm" : "h:mm AP");
    }

    function dayKey(d) {
        return d.getFullYear() * 10000 + (d.getMonth() + 1) * 100 + d.getDate();
    }

    function colorOf(e) {
        return e.color !== "" ? e.color : fallbackColors[e.colorIdx % fallbackColors.length];
    }

    function eventsOn(date) {
        return byDay[dayKey(date)]?.events ?? [];
    }

    function hasEvents(date) {
        return eventsOn(date).length > 0;
    }

    function dotsOn(date) {
        return byDay[dayKey(date)]?.dots ?? [];
    }

    // Spans multi-day and past-midnight events across every day they touch.
    function index(list) {
        const map = {};
        for (const e of list) {
            const d = new Date(e.start);
            d.setHours(0, 0, 0, 0);
            const last = Math.max(e.start, e.end - 1); // end is exclusive; instants count on their day
            for (let i = 0; d.getTime() <= last && i < 64; i++) {
                const k = dayKey(d);
                const slot = map[k] ?? (map[k] = { events: [], dots: [] });
                slot.events.push(e);
                const c = colorOf(e);
                if (slot.dots.length < 3 && !slot.dots.includes(c))
                    slot.dots.push(c);
                d.setDate(d.getDate() + 1);
            }
        }
        for (const k in map)
            map[k].events.sort((a, b) => (b.allDay - a.allDay) || a.start - b.start);
        return map;
    }

    function open(link) {
        if (/^https?:\/\//.test(link))
            Quickshell.execDetached(["xdg-open", link]);
    }

    // Starts calendar-sync now; the cache watcher picks the result up.
    function refresh() {
        if (!sync.running) {
            syncing = true;
            sync.running = true;
        }
    }

    // --- Boundary timer and reminders ----------------------------------------
    function arm() {
        const t = Date.now();
        now = t;
        const remind = Settings.calendarRemindMin * 60000, chip = Settings.calendarChipMin * 60000;
        const midnight = new Date(t);
        midnight.setHours(24, 0, 0, 0);
        let b = midnight.getTime();
        for (const e of events) {
            if (e.end < t)
                continue;
            for (const x of [e.start, e.end, e.start - remind, e.start - chip, e.start - lineWindowMs])
                if (x > t && x < b)
                    b = x;
        }
        boundary.interval = Math.min(maxSleepMs, Math.max(1000, b - t + 250)); // +250: land just past it
        boundary.restart();
    }

    // One toast per event, ever: ids persist with the event's end for pruning.
    property var notified: ({})

    function remind() {
        const lead = Settings.calendarRemindMin * 60000;
        if (lead <= 0)
            return;
        const t = Date.now();
        let changed = false;
        for (const e of events) {
            if (e.allDay || e.start <= t || e.start - t > lead || notified[e.id])
                continue;
            notified[e.id] = e.end;
            changed = true;
            toast(e, t);
        }
        for (const id in notified)
            if (notified[id] < t - 86400000) {
                delete notified[id];
                changed = true;
            }
        if (changed)
            seen.setText(JSON.stringify(notified));
    }

    function toast(e, t) {
        const body = fmtTime(e.start) + " – " + fmtTime(e.end) + (e.location ? "  ·  " + e.location : "");
        const base = ["notify-send", "-a", "Calendar", "-i", "x-office-calendar", e.title, body];
        if (!e.link) {
            Quickshell.execDetached(base);
            return;
        }
        // -A waits for the click and prints the action; `timeout` keeps the waiter from outliving the event.
        const secs = Math.max(60, Math.round((e.end - t) / 1000));
        const cmd = ["timeout", String(secs), "notify-send", "-A", "join=Join", "-a", "Calendar", "-i", "x-office-calendar", e.title, body];
        waiter.createObject(root, { command: cmd, link: e.link, running: true });
    }

    Component {
        id: waiter

        Process {
            id: proc

            property string link

            stdout: StdioCollector {
                onStreamFinished: if (text.trim() === "join")
                    root.open(proc.link)
            }
            onExited: Qt.callLater(proc.destroy)
        }
    }

    Timer {
        id: boundary

        onTriggered: {
            root.arm();
            root.remind();
        }
    }

    Connections {
        target: Settings

        function onCalendarRemindMinChanged() {
            root.arm();
            root.remind();
        }

        function onCalendarChipMinChanged() {
            root.arm();
        }
    }

    function load(text) {
        try {
            const d = JSON.parse(text);
            syncedAt = d.syncedAt * 1000;
            calendars = d.calendars;
            events = d.events.map(e => Object.assign(e, { start: e.start * 1000, end: e.end * 1000 }));
        } catch (e) {
            events = [];
        }
        arm();
        remind();
    }

    FileView {
        path: root.cachePath
        blockLoading: true
        printErrors: false // missing until the first sync
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.load(text())
    }

    FileView {
        id: seen

        path: Quickshell.statePath("calendar-notified.json")
        blockLoading: true
        printErrors: false
        atomicWrites: true
        onLoaded: {
            try {
                root.notified = JSON.parse(text());
            } catch (e) {}
        }
    }

    Process {
        id: sync

        command: ["systemctl", "--user", "start", "calendar-sync.service"]
        onExited: root.syncing = false
    }
}
