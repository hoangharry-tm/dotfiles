import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

// Apple-style Control Center under the bar's right end.
PanelWindow {
    id: root

    required property ShellScreen modelData
    readonly property bool shown: modelData ? Panels.isOpen("control", modelData.name) : false

    // Which detail list is expanded: "", "wifi", "bluetooth", "sound"
    property string detail: ""
    // Which module is expanded (a CcCard kind), "" = none.
    property string module: ""

    // First show pays for the render thread, GL context and shader setup
    // (2-3 s). Map a 1x1 surface once at startup so the real open is cheap.
    property bool warm: true

    screen: modelData
    visible: shown || warm
    anchors.top: true
    anchors.right: true
    margins.top: Theme.popoverTop
    margins.right: Theme.edge
    implicitWidth: shown ? Theme.panelWidth : 1
    // Sized to the content at rest (everything collapsed, never shorter than
    // Theme.panelHeight), capped by the screen. Measured only just after
    // opening (hidden items drop out of layouts, so a closed measure is short)
    // and then frozen: expanded rows scroll inside the sheet. A layer-surface
    // resize makes niri re-blur and re-shadow the whole sheet, and following
    // the content live lagged on the T480. The last height is kept, so a
    // reopen with unchanged content never resizes at all.
    property real restHeight: Theme.panelHeight
    property bool settled: true
    Timer {
        id: settle

        interval: Theme.settleDelay
        onTriggered: root.settled = true
    }
    Binding {
        when: root.shown && !root.settled
        target: root
        property: "restHeight"
        value: Theme.padSheet * 2 + footer.height + Theme.gapSection + layout.implicitHeight
        restoreMode: Binding.RestoreNone
    }
    implicitHeight: !shown ? 1 : Math.min(Math.max(Theme.panelHeight, restHeight), (modelData?.height ?? 0) - margins.top - Theme.edge)
    // Ignore the bar's exclusive zone, else margins.top (already measured
    // from the screen edge) is added below the bar a second time.
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.namespace: "qs-control-center"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Timer {
        running: root.warm
        interval: Theme.warmKeep
        onTriggered: root.warm = false
    }

    function toggleDetail(name) {
        detail = detail === name ? "" : name;
    }
    function toggleModule(name) {
        module = module === name ? "" : name;
    }

    onShownChanged: {
        if (shown) {
            ccScroll.contentY = 0; // always open at the top
            settled = false;
            settle.restart();
        } else {
            detail = "";
            module = "";
        }
    }
    onDetailChanged: {
        // Scans are opt-in (refresh button) and end with their dropdown.
        if (detail !== "wifi")
            Network.stopScan();
        if (detail !== "bluetooth")
            BluetoothState.stopScan();
    }

    Glass {
        id: sheet

        anchors.fill: parent
        radius: Theme.radiusXl // = qs-control-center layer rule in niri/rules.kdl
        focus: true
        Keys.onEscapePressed: Panels.close()

        Flickable {
            id: ccScroll
            anchors.fill: parent
            anchors.margins: Theme.padSheet
            // The sheet is full height, so session actions sit on its bottom
            // edge (always reachable); the content scrolls above them.
            anchors.bottomMargin: Theme.padSheet + footer.height + Theme.gapSection
            contentHeight: layout.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            // Hold presses briefly: a scroll/drag that starts on a control (power
            // mode, tiles) must scroll the page, never land as a click on it.
            pressDelay: Theme.pressDelay

            SmoothWheel {
                flick: ccScroll
            }

            TilesLayout {
                id: layout

                width: parent.width
                cc: root
            }
        }

        Footer {
            id: footer

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Theme.padSheet
        }
    }
}
