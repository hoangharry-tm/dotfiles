pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

// One countdown timer tied to Focus (DND). The user sets a duration, plays,
// pauses and resets; there are no phases. Focus turns on while it is active
// unless the user already had it on (then it is left alone) and turns off when
// the timer ends or is reset. At zero one notification is posted (after Focus
// is released, so it is not muted) and the timer returns to idle.
//
// Cost model: remaining time is derived from a wall-clock end timestamp, never
// from counting ticks. One single-shot timer fires at the end; a 1 s tick runs
// only while `secWatchers` > 0 (a visible mm:ss), a slow one while only a ring
// is visible, none otherwise.
//
// The duration is Settings.focusDefaultMin: the last one used, which is also
// the "Default duration" setting. State survives a shell restart in
// focus-timer.json (see FileView below).
Singleton {
    id: root

    readonly property real minMinutes: 0.1  // 6 s; below the UI's 1 min step, reachable via IPC
    readonly property real maxMinutes: 600
    readonly property bool active: state.active
    readonly property bool running: state.active && state.running
    readonly property bool paused: state.active && !state.running
    readonly property int todayCount: state.day === dayKey() ? state.today : 0

    property real now: Date.now()   // refreshed by ticks and every transition
    property int secWatchers: 0     // visible items that show seconds
    property int ringWatchers: 0    // visible items that show only progress

    // Idle shows the chosen duration; an active timer its own (set at play).
    readonly property real durationMs: active ? state.totalMs : Settings.focusDefaultMin * 60000
    readonly property real remainingMs: running ? Math.max(0, state.endMs - now) : active ? state.leftMs : durationMs
    readonly property real fraction: Math.min(1, Math.max(0, remainingMs / Math.max(1, durationMs))) // 1 = full ring
    readonly property string clockText: format(remainingMs)

    function dayKey() {
        return new Date().toDateString();
    }

    function format(ms) {
        const s = Math.ceil(ms / 1000);
        return String(Math.floor(s / 60)).padStart(2, "0") + ":" + String(s % 60).padStart(2, "0");
    }

    // ---- Actions -----------------------------------------------------------

    // Chosen duration; editable while idle or paused (a paused timer restarts
    // from the new length), ignored while running.
    function setMinutes(m) {
        if (running || !(m > 0))
            return;
        m = Math.min(maxMinutes, Math.max(minMinutes, m));
        Settings.focusDefaultMin = m;
        if (paused) {
            state.totalMs = m * 60000;
            state.leftMs = state.totalMs;
            save();
        }
    }

    function stepMinutes(delta) {
        setMinutes(Math.max(1, Math.round(Settings.focusDefaultMin) + delta));
    }

    // Play: start from idle, or resume from pause.
    function play() {
        now = Date.now();
        if (running)
            return;
        if (!active) {
            state.totalMs = Settings.focusDefaultMin * 60000;
            state.leftMs = state.totalMs;
            state.active = true;
            if (!Notifications.dnd) {
                Notifications.dnd = true;
                state.ownDnd = true;
            }
        }
        state.endMs = now + state.leftMs;
        state.running = true;
        save();
    }

    function pause() {
        if (!running)
            return;
        now = Date.now();
        state.leftMs = Math.max(0, state.endMs - now);
        state.running = false;
        save();
    }

    function toggle() {
        running ? pause() : play();
    }

    function reset() {
        if (!active)
            return;
        releaseDnd();
        state.active = false;
        state.running = false;
        save();
    }

    // Show the timer card under the clock on the focused screen.
    function openCard() {
        if (!Panels.isOpen("timer", Panels.focusedScreen()))
            Panels.toggle("timer");
    }

    // Natural end: credit it, release Focus first, then announce.
    function finish() {
        const mins = Math.round(state.totalMs / 600) / 100;
        state.today = todayCount + 1;
        state.day = dayKey();
        reset();
        notify("Timer done — " + mins + " min", "Focus is off again");
    }

    // ---- Focus (DND) integration -------------------------------------------

    // Only touch Focus we turned on ourselves; a manual Focus is never undone.
    function releaseDnd() {
        if (state.ownDnd)
            Notifications.dnd = false;
        state.ownDnd = false;
    }

    function notify(summary, body) {
        Quickshell.execDetached(["notify-send", "-a", "Focus timer", "-i", "alarm-symbolic", "-t", "6000", summary, body]);
    }

    // ---- Timing ------------------------------------------------------------

    Timer {
        // Wall-clock end; re-armed whenever the end or run state changes.
        interval: Math.max(1, state.endMs - Date.now())
        running: root.running
        onTriggered: root.finish()
    }

    Timer {
        interval: root.secWatchers > 0 ? 1000 : 15000
        repeat: true
        running: root.running && (root.secWatchers > 0 || root.ringWatchers > 0)
        triggeredOnStart: true
        onTriggered: root.now = Date.now()
    }

    // ---- Persistence -------------------------------------------------------

    // Every state change goes through the adapter, which fires onAdapterUpdated.
    // Writes are coalesced: one transition changes several fields, and atomic
    // writes started back to back drop all but one (leaving a torn file).
    function save() {}

    Timer {
        id: saveTimer

        interval: 100
        onTriggered: file.writeAdapter()
    }

    FileView {
        id: file

        path: Quickshell.statePath("focus-timer.json")
        blockLoading: true // state must be known before the bar shows the chip
        printErrors: false // missing on first run
        atomicWrites: true
        onAdapterUpdated: saveTimer.restart()
        // Resume: a timer that ended while the shell was down finishes once.
        // Old Pomodoro files have no `active`, so they load as idle; drop the
        // Focus they may still own.
        onLoaded: {
            root.now = Date.now();
            if (!state.active)
                root.releaseDnd();
            else if (state.running && state.endMs <= root.now)
                root.finish();
        }

        JsonAdapter {
            id: state

            property bool active: false
            property bool running: false
            property real totalMs: 0   // length of the current run
            property real endMs: 0     // wall-clock end while running
            property real leftMs: 0    // remaining while paused
            property int today: 0
            property string day: ""
            property bool ownDnd: false // we turned Focus on, so we turn it off
        }
    }
}
