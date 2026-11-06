pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Notification daemon (org.freedesktop.Notifications), history and toasts.
Singleton {
    id: root

    property bool dnd: false
    property var toasts: []          // notifications currently shown as toasts
    property var received: ({})      // id -> Date (the protocol has no timestamp)
    readonly property var history: server.trackedNotifications.values.slice().reverse()

    function dismiss(n) {
        hide(n);
        n.dismiss();
    }

    function hide(n) {
        toasts = toasts.filter(t => t !== n);
    }

    function clearAll() {
        toasts = [];
        for (const n of server.trackedNotifications.values.slice())
            n.dismiss();
    }

    function timeAgo(n) {
        const t = received[n.id];
        if (!t)
            return "";
        const s = (Date.now() - t.getTime()) / 1000;
        return s < 60 ? "now" : s < 3600 ? Math.floor(s / 60) + "m" : s < 86400 ? Math.floor(s / 3600) + "h" : Qt.formatDate(t, "d MMM");
    }

    // Seconds to show a toast; 0 = until dismissed.
    function timeoutOf(n) {
        if (n.urgency === NotificationUrgency.Critical)
            return 0;
        return n.expireTimeout > 0 ? n.expireTimeout : 5;
    }

    NotificationServer {
        id: server

        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true;
            const r = Object.assign({}, root.received);
            r[n.id] = new Date();
            root.received = r;
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                root.toasts = [n].concat(root.toasts).slice(0, 4);
        }
    }
}
