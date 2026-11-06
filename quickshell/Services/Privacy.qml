pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Which apps are capturing the microphone or screen right now, from PipeWire
// stream nodes. Drives the bar's privacy dot.
Singleton {
    id: root

    // The shell's own cava visualiser records the sink monitor, not a mic: it
    // must not light the dot (its infinite pulse re-renders every bar at
    // 60 fps, ~20% CPU while media plays).
    function _apps(flag) {
        return Pipewire.nodes.values.filter(n => n.isStream && (n.type & flag) === flag && n.name !== "cava").map(n => n.properties["application.name"] || n.description || n.name);
    }

    readonly property var micApps: _apps(PwNodeType.AudioInStream)
    // Screen capture and cameras both appear as video streams.
    readonly property var videoApps: _apps(PwNodeType.Video | PwNodeType.Stream | PwNodeType.Source)

    readonly property bool micActive: micApps.length > 0
    readonly property bool videoActive: videoApps.length > 0
    readonly property bool active: micActive || videoActive
}
