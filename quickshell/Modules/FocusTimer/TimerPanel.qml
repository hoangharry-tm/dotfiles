import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Widgets

// The timer card as a small panel at the top centre, under the clock: how
// Mod+P, the launcher and the Focus menu reach it when the bar chip is hidden
// (idle). Loaded only while open (see shell.qml). Starting or Esc closes it.
PanelWindow {
    id: root

    required property ShellScreen modelData

    screen: modelData
    anchors.top: true
    exclusionMode: ExclusionMode.Ignore // margin is measured from the screen edge, not below the bar
    margins.top: Theme.popoverTop
    implicitWidth: card.implicitWidth + Theme.padCard * 2
    implicitHeight: card.implicitHeight + Theme.padCard * 2
    color: "transparent"
    // Shares the popover's niri layer rule (radiusLg glass, shadow).
    WlrLayershell.namespace: "qs-popover"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Glass {
        anchors.fill: parent
        radius: Theme.radiusLg

        // Esc is handled here so the time field can swallow it first.
        FocusScope {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: Panels.close()

            TimerCard {
                id: card

                x: Theme.padCard
                y: Theme.padCard
                onStarted: Panels.close()
            }
        }
    }
}
