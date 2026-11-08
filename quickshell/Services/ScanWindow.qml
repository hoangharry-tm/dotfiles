import QtQuick

// A bounded scan: starts on request and always ends by itself (single-shot
// timer), so a radio never scans unattended. The 5 s tick runs only while
// scanning, to keep the "minutes left" label fresh.
QtObject {
    id: root

    property bool active: false
    property real endsAt: 0          // epoch ms, 0 when idle
    property real now: Date.now()
    readonly property int minutesLeft: active ? Math.max(1, Math.ceil((endsAt - now) / 60000)) : 0

    signal begin
    signal end

    function start(ms) {
        endsAt = Date.now() + ms;
        now = Date.now();
        active = true;
        timeout.interval = ms;
        timeout.restart();
        begin();
    }

    function stop() {
        if (!active)
            return;
        active = false;
        endsAt = 0;
        timeout.stop();
        end();
    }

    property Timer _timeout: Timer {
        id: timeout

        onTriggered: root.stop()
    }

    property Timer _tick: Timer {
        running: root.active
        interval: 5000
        repeat: true
        onTriggered: root.now = Date.now()
    }
}
