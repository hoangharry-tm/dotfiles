import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common

// Invisible full-screen catcher under an open popout: clicking anywhere else
// closes it (layer-shell surfaces can't see clicks outside themselves).
// Mapped on every output, not just the popout's: with two monitors a click
// on the other screen used to do nothing. Closes on press (not click), so a
// press that drifts or a release that lands elsewhere still counts.
PanelWindow {
    required property ShellScreen modelData

    screen: modelData
    visible: Panels.open !== "" && Panels.open !== "power"
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.namespace: "qs-scrim"
    WlrLayershell.layer: WlrLayer.Top

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: Panels.close()
    }
}
