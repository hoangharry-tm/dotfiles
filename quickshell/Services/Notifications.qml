pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// Notification daemon (org.freedesktop.Notifications): history, toasts,
// grouping by app, Focus (do not disturb) with schedule and timer.
//
// SETTINGS live in one file, edited by hand or by the Focus menu (applied
// live): Quickshell.statePath("notifications.json"), i.e.
// ~/.local/state/quickshell/by-shell/<id>/notifications.json
//   scheduleEnabled  bool    Focus turns on/off at the times below
//   scheduleStart    "HH:MM" e.g. "22:00"
//   scheduleEnd      "HH:MM" e.g. "07:00" (may be earlier than start: overnight)
//   persistHistory   bool    keep history across shell restarts (opt-in)
//
// PRIVACY TRADE-OFF: persistHistory writes summaries and bodies to
// notification-history.json (plain text, user-readable) so a restart does not
// lose them. Off by default: history is then in memory only. Images are never
// persisted; restored entries have no actions or reply.
Singleton {
    id: root

    // Manual or automatic Focus. The schedule flips it on its edges only, so a
    // manual toggle inside the window sticks until the next edge.
    property bool dnd: false
    property var toasts: []                 // notifications currently shown as toasts
    property var received: ({})             // id -> Date (the protocol has no timestamp)
    property var restored: []               // plain objects loaded from disk (older than live ones)
    property var expanded: ({})             // group key -> true
    property real focusUntil: 0             // ms epoch; 0 = no timer
    property int tick: 0                    // bumps once a minute while a card is visible
    property int watchers: 0                // visible cards that show a relative time

    readonly property int maxHistory: 50
    readonly property int maxToastGroups: 3
    readonly property int maxToasts: 12
    readonly property alias scheduleEnabled: settings.scheduleEnabled
    readonly property alias scheduleStart: settings.scheduleStart
    readonly property alias scheduleEnd: settings.scheduleEnd
    readonly property alias persistHistory: settings.persistHistory

    readonly property var live: server.trackedNotifications.values.slice().reverse()
    readonly property var history: {
        // A shell reload keeps live ones (keepOnReload) which the file also has.
        const seen = new Set(live.map(sig));
        return live.concat(restored.filter(r => !seen.has(sig(r)))).slice(0, maxHistory);
    }
    readonly property var historyIndex: indexOf(history)
    readonly property var toastIndex: indexOf(toasts)
    readonly property var groupKeys: historyIndex.keys
    readonly property var toastKeys: toastIndex.keys.slice(0, maxToastGroups)

    // Cards shown for a group when `expanded`, else only the latest.
    function itemsIn(index, key) {
        return index.map[key] ?? [];
    }

    function keyOf(n) {
        return (n.desktopEntry || n.appName || "app").toLowerCase();
    }

    function sig(n) {
        return n.appName + "\n" + n.summary + "\n" + n.body;
    }

    // Newest-first list -> {keys: [by latest activity], map: key -> items}.
    function indexOf(list) {
        const keys = [], map = {};
        for (const n of list) {
            const k = keyOf(n);
            if (!map[k]) {
                map[k] = [];
                keys.push(k);
            }
            map[k].push(n);
        }
        return { keys, map };
    }

    function toggleGroup(key) {
        const e = Object.assign({}, expanded);
        if (e[key])
            delete e[key];
        else
            e[key] = true;
        expanded = e;
    }

    function dismiss(n) {
        hide(n);
        if (typeof n.dismiss === "function")
            n.dismiss();
        else
            restored = restored.filter(r => r !== n);
    }

    function dismissAll(items) {
        for (const n of items.slice())
            dismiss(n);
    }

    function hide(n) {
        toasts = toasts.filter(t => t !== n);
    }

    function hideAll(items) {
        toasts = toasts.filter(t => !items.includes(t));
    }

    function clearAll() {
        toasts = [];
        restored = [];
        for (const n of server.trackedNotifications.values.slice())
            n.dismiss();
    }

    // Icon of the app behind a notification ("" when unknown).
    function appIconOf(n) {
        if (n.appIcon)
            return n.appIcon.startsWith("/") || n.appIcon.startsWith("file:") ? n.appIcon : Quickshell.iconPath(n.appIcon, true);
        const entry = n.desktopEntry ? DesktopEntries.byId(n.desktopEntry) : null;
        return entry ? Quickshell.iconPath(entry.icon, true) : "";
    }

    function timeOf(n) {
        return n.time ? new Date(n.time) : received[n.id];
    }

    // "now", "5m", "2h", "3 Nov". Reads `tick`, so bindings refresh each minute.
    function timeAgo(n) {
        tick;
        const t = timeOf(n);
        if (!t)
            return "";
        const s = (Date.now() - t.getTime()) / 1000;
        return s < 60 ? "now" : s < 3600 ? Math.floor(s / 60) + "m" : s < 86400 ? Math.floor(s / 3600) + "h" : Qt.formatDate(t, "d MMM");
    }

    // Seconds to show a toast; 0 = until dismissed (critical never expires).
    function timeoutOf(n) {
        if (n.urgency === NotificationUrgency.Critical)
            return 0;
        return n.expireTimeout > 0 ? n.expireTimeout : 5;
    }

    function groupTimeout(items) {
        let max = 0;
        for (const n of items) {
            const t = timeoutOf(n);
            if (t === 0)
                return 0;
            max = Math.max(max, t);
        }
        return max;
    }

    // Opens the notification: default action, then focus the app's window.
    function activate(n) {
        const def = (n.actions ?? []).find(a => a.identifier === "default");
        if (def)
            def.invoke();
        focusApp(n);
        if (!n.resident)
            dismiss(n);
    }

    // niri has no activation-token path from here, so find the window by app-id.
    function focusApp(n) {
        const ids = [n.desktopEntry, n.appName].filter(s => s).map(s => s.toLowerCase().replace(/\.desktop$/, ""));
        const win = Object.values(Niri.windows).find(w => {
            const a = (w.app_id ?? "").toLowerCase();
            return a && ids.some(i => i === a || i.endsWith("." + a) || a.endsWith("." + i));
        });
        if (win)
            Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", String(win.id)]);
    }

    // ---- Focus -------------------------------------------------------------

    function focusFor(minutes) {
        setFocusUntil(Date.now() + minutes * 60000);
    }

    // Until the next HH:MM (e.g. the schedule's end).
    function focusUntilTime(hhmm) {
        const [h, m] = hhmm.split(":").map(Number);
        const d = new Date();
        d.setHours(h, m, 0, 0);
        if (d.getTime() <= Date.now())
            d.setDate(d.getDate() + 1);
        setFocusUntil(d.getTime());
    }

    function setFocusUntil(ms) {
        focusUntil = ms;
        dnd = true;
        focusTimer.interval = Math.max(1, ms - Date.now());
        focusTimer.restart();
        settings.focusUntil = ms;
        saveSettings();
    }

    function setSchedule(enabled) {
        settings.scheduleEnabled = enabled;
        saveSettings();
    }

    function setPersist(on) {
        settings.persistHistory = on;
        saveSettings();
        saveHistory.restart(); // writes the list, or empties the file when off
    }

    function saveSettings() {
        settingsFile.writeAdapter();
    }

    onDndChanged: {
        if (!dnd && focusUntil > 0) {
            focusUntil = 0;
            focusTimer.stop();
            settings.focusUntil = 0;
            saveSettings();
        }
    }

    // Schedule: one timer to the next edge, no polling.
    property bool wasInWindow: false

    function minutesOf(hhmm) {
        const [h, m] = (hhmm || "0:0").split(":").map(Number);
        return (h || 0) * 60 + (m || 0);
    }

    function inWindow(nowMin) {
        const s = minutesOf(scheduleStart), e = minutesOf(scheduleEnd);
        return s === e ? false : s < e ? nowMin >= s && nowMin < e : nowMin >= s || nowMin < e;
    }

    function applySchedule() {
        if (!scheduleEnabled) {
            edge.stop();
            wasInWindow = false;
            return;
        }
        const now = new Date();
        const nowMin = now.getHours() * 60 + now.getMinutes();
        const inside = inWindow(nowMin);
        if (inside !== wasInWindow) {
            wasInWindow = inside;
            if (inside)
                dnd = true;
            else if (dnd && focusUntil <= 0)
                dnd = false;
        }
        const sinceMinute = now.getSeconds() * 1000 + now.getMilliseconds();
        const toEdge = t => (((minutesOf(t) - nowMin) + 1440) % 1440 || 1440) * 60000 - sinceMinute;
        edge.interval = Math.max(1000, Math.min(toEdge(scheduleStart), toEdge(scheduleEnd)));
        edge.restart();
    }

    onScheduleEnabledChanged: applySchedule()
    onScheduleStartChanged: applySchedule()
    onScheduleEndChanged: applySchedule()

    Timer {
        id: edge

        onTriggered: root.applySchedule()
    }

    Timer {
        id: focusTimer

        onTriggered: root.dnd = false // onDndChanged clears the rest
    }

    // Relative times: one tick a minute, only while a card is on screen.
    Timer {
        interval: 60000
        repeat: true
        running: root.watchers > 0
        onRunningChanged: if (running)
            root.tick++
        onTriggered: root.tick++
    }

    // ---- Persistence -------------------------------------------------------

    FileView {
        id: settingsFile

        path: Quickshell.statePath("notifications.json")
        blockLoading: true // tiny; Focus state must be known before the first notification
        watchChanges: true // hand edits apply live
        printErrors: false // missing on first run
        onFileChanged: reload()
        onLoaded: root.applySettings()

        JsonAdapter {
            id: settings

            property bool scheduleEnabled: false
            property string scheduleStart: "22:00"
            property string scheduleEnd: "07:00"
            property bool persistHistory: false
            property real focusUntil: 0
        }
    }

    function applySettings() {
        const left = settings.focusUntil - Date.now();
        if (left > 0 && focusUntil !== settings.focusUntil) {
            focusUntil = settings.focusUntil;
            dnd = true;
            focusTimer.interval = left;
            focusTimer.restart();
        }
        applySchedule();
    }

    Component.onCompleted: applySettings()

    FileView {
        id: historyFile

        path: settings.persistHistory ? Quickshell.statePath("notification-history.json") : ""
        printErrors: false
        onLoaded: {
            try {
                root.restored = JSON.parse(text()).slice(0, root.maxHistory);
            } catch (e) {
                root.restored = [];
            }
        }
    }

    // Debounced: bursts of notifications cost one write.
    Timer {
        id: saveHistory

        interval: 1000
        onTriggered: historyFile.setText(JSON.stringify(settings.persistHistory ? root.history.map(n => ({
                        appName: n.appName,
                        appIcon: n.appIcon,
                        desktopEntry: n.desktopEntry,
                        summary: n.summary,
                        body: n.body,
                        urgency: n.urgency,
                        time: (root.timeOf(n) ?? new Date()).getTime()
                    })) : []))
    }

    onHistoryChanged: if (settings.persistHistory)
        saveHistory.restart()

    NotificationServer {
        id: server

        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        actionsSupported: true
        imageSupported: true
        inlineReplySupported: true

        onNotification: n => {
            n.tracked = true;
            const r = Object.assign({}, root.received);
            r[n.id] = new Date();
            root.received = r;
            // Bounded history: drop the oldest live ones.
            const all = server.trackedNotifications.values;
            for (let i = 0; i < all.length - root.maxHistory; i++)
                all[i].dismiss();
            // Focus mutes everything except critical.
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                root.toasts = [n].concat(root.toasts).slice(0, root.maxToasts);
        }
    }
}
