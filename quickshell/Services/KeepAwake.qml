pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Wayland

// "Keep awake": inhibit idle (screen off / lock / suspend) while on.
// The Wayland inhibitor needs a visible surface, so while enabled a 1x1
// transparent background layer surface carries it; nothing exists when off.
Singleton {
    id: root

    property bool enabled: false

    LazyLoader {
        active: root.enabled

        PanelWindow {
            id: carrier

            implicitWidth: 1
            implicitHeight: 1
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "qs-keep-awake"

            IdleInhibitor {
                enabled: true
                window: carrier
            }
        }
    }
}
