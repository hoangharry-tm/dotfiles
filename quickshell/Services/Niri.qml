pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Workspaces and windows, kept live from niri's event stream (IPC socket).
// https://niri-wm.github.io/niri/IPC.html
Singleton {
    id: root

    property var workspaces: []     // sorted by output, then index
    property var windows: ({})      // id -> window
    property int focusedWindowId: -1

    // Most-recently-used window ids, newest first. Maintained from focus
    // events (no polling); consumed by the Alt+Tab switcher.
    property var mru: []

    function touch(id) {
        if (id === null || id === undefined || id < 0 || mru[0] === id)
            return;
        mru = [id].concat(mru.filter(i => i !== id));
    }

    readonly property var focusedWindow: windows[focusedWindowId] ?? null

    function workspacesOn(output) {
        return workspaces.filter(w => w.output === output);
    }

    function windowsOn(workspaceId) {
        return Object.values(windows).filter(w => w.workspace_id === workspaceId);
    }

    function focusWorkspace(id) {
        send({ Action: { FocusWorkspace: { reference: { Id: id } } } });
    }

    function action(name, args) {
        send({ Action: { [name]: args ?? {} } });
    }

    function send(request) {
        requests.write(JSON.stringify(request) + "\n");
        requests.flush();
    }

    function handle(event) {
        const [type, data] = Object.entries(event)[0] ?? [];
        switch (type) {
        case "WorkspacesChanged":
            workspaces = data.workspaces.sort((a, b) => a.output.localeCompare(b.output) || a.idx - b.idx);
            break;
        case "WorkspaceActivated": {
            const target = workspaces.find(w => w.id === data.id);
            if (!target)
                break;
            workspaces = workspaces.map(w => Object.assign({}, w, {
                is_active: w.output === target.output ? w.id === data.id : w.is_active,
                is_focused: data.focused ? w.id === data.id : w.is_focused
            }));
            break;
        }
        case "WorkspaceActiveWindowChanged":
            workspaces = workspaces.map(w => w.id === data.workspace_id ? Object.assign({}, w, {
                active_window_id: data.active_window_id
            }) : w);
            break;
        case "WindowsChanged": {
            const map = {};
            for (const w of data.windows) {
                map[w.id] = w;
                if (w.is_focused)
                    focusedWindowId = w.id;
            }
            windows = map;
            // Seed history from niri's own focus timestamps (newest first).
            const stamp = w => w.focus_timestamp ? w.focus_timestamp.secs * 1e9 + w.focus_timestamp.nanos : -1;
            mru = data.windows.slice().sort((a, b) => stamp(b) - stamp(a)).map(w => w.id);
            break;
        }
        case "WindowOpenedOrChanged": {
            const map = Object.assign({}, windows);
            map[data.window.id] = data.window;
            windows = map;
            if (data.window.is_focused) {
                focusedWindowId = data.window.id;
                touch(data.window.id);
            } else if (!mru.includes(data.window.id)) {
                mru = mru.concat([data.window.id]);   // new unfocused windows rank last
            }
            break;
        }
        case "WindowClosed": {
            const map = Object.assign({}, windows);
            delete map[data.id];
            windows = map;
            mru = mru.filter(i => i !== data.id);
            break;
        }
        case "WindowFocusChanged":
            focusedWindowId = data.id ?? -1;
            touch(data.id);
            break;
        }
    }

    Socket {
        id: events

        path: Quickshell.env("NIRI_SOCKET")
        connected: true
        onConnectionStateChanged: {
            if (connected) {
                write('"EventStream"\n');
                flush();
            } else {
                reconnect.start();
            }
        }

        parser: SplitParser {
            onRead: line => {
                try {
                    root.handle(JSON.parse(line));
                } catch (e) {
                    // The first reply is {"Ok":"Handled"}; ignore anything unparseable.
                }
            }
        }
    }

    Socket {
        id: requests

        path: Quickshell.env("NIRI_SOCKET")
        connected: true
        parser: SplitParser {}
    }

    Timer {
        id: reconnect

        interval: 1000
        onTriggered: events.connected = true
    }
}
