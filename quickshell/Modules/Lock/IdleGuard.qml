import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Services

// Smart idle: keep the screen awake while media plays or a screen
// recording/cast (or camera) is live. Same mechanism as Services/KeepAwake
// (a 1x1 background surface carries the Wayland idle inhibitor), but driven
// by Mpris/PipeWire signals, so there is no polling at all.
Scope {
    id: root

    readonly property bool wanted: Media.playing || Recorder.recording || Privacy.videoActive

    LazyLoader {
        active: root.wanted

        PanelWindow {
            id: carrier

            implicitWidth: 1
            implicitHeight: 1
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "qs-idle-guard"

            IdleInhibitor {
                enabled: true
                window: carrier
            }
        }
    }
}
