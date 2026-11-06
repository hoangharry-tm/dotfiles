pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Who is capturing right now. Screen sharing comes from niri's cast list (the
// compositor knows every cast, incl. wlr-screencopy that never touches
// PipeWire); microphone and camera come from PipeWire stream nodes.
Singleton {
    id: root

    // The shell's own cava visualiser records the sink monitor, not a mic: it
    // must not light the dot (its infinite pulse re-renders every bar at
    // 60 fps, ~20% CPU while media plays).
    function _apps(flag, skip) {
        return Pipewire.nodes.values.filter(n => n.isStream && (n.type & flag) === flag && n.name !== "cava" && !skip.includes(n.id)).map(n => n.properties["application.name"] || n.description || n.name);
    }

    function _target(c) {
        if (c.output)
            return c.output;
        const w = Niri.windows[c.window];
        return w ? (w.title || w.app_id || "Window") : "Window";
    }

    // [{id (session, what stop-cast takes), target, app}], one per session.
    readonly property var casts: {
        const seen = new Set();
        return Niri.casts.filter(c => !seen.has(c.id) && seen.add(c.id)).map(c => ({
                    id: c.id,
                    target: _target(c),
                    app: Pipewire.nodes.values.find(n => n.id === c.pwNode)?.properties["application.name"] ?? ""
                }));
    }

    readonly property var micApps: _apps(PwNodeType.AudioInStream, [])
    // Video streams that are not niri's own cast nodes are cameras.
    readonly property var cameraApps: _apps(PwNodeType.Video | PwNodeType.Stream | PwNodeType.Source, Niri.casts.map(c => c.pwNode))

    readonly property bool sharing: casts.length > 0
    readonly property bool micActive: micApps.length > 0
    readonly property bool cameraActive: cameraApps.length > 0
    // Anything on screen/camera: keeps the idle inhibitor (IdleGuard) on.
    readonly property bool videoActive: sharing || cameraActive
    readonly property bool active: micActive || cameraActive   // PrivacyDot; sharing has its own chip
}
