import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services

// Invisible hot strip on the bottom edge, centred. Pointer contact reveals
// the dock. It stops well short of the corners so the bottom-right hot
// corner (overview) keeps working. No timers, no rendering: idle cost zero.
PanelWindow {
    id: root

    required property ShellScreen modelData

    screen: modelData
    anchors.bottom: true
    implicitWidth: Math.min(Theme.launcherWidth, modelData.width / 2)
    implicitHeight: Theme.spaceXs
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.namespace: "qs-dock-trigger"
    WlrLayershell.layer: WlrLayer.Top

    HoverHandler {
        onHoveredChanged: hovered ? Dock.reveal(root.modelData.name) : Dock.edgeLeft(root.modelData.name)
    }
}
