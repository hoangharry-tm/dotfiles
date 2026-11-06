import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common

// Invisible full-screen catcher under an open popout: clicking anywhere else
// closes it (layer-shell surfaces can't see clicks outside themselves).
PanelWindow {
    required property ShellScreen modelData

    screen: modelData
    visible: Panels.open !== "" && Panels.open !== "power" && Panels.screen === modelData.name
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
        onClicked: Panels.close()
    }
}
