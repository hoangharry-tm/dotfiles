import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

// Apple-style Control Center under the bar's right end.
PanelWindow {
    id: root

    required property ShellScreen modelData
    readonly property bool shown: Panels.isOpen("control", modelData.name)

    // Which detail list is expanded: "", "wifi", "bluetooth", "sound"
    property string detail: ""
    // "tiles" style: which module is expanded (a CcCard kind), "" = none.
    property string module: ""
    // "pages" style: the visible page.
    property string page: "home"

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
    implicitHeight: !shown ? 1 : Math.min(content.itemHeight + Theme.padSheet * 2, modelData.height - margins.top - Theme.edge)
    // Ignore the bar's exclusive zone, else margins.top (already measured
    // from the screen edge) is added below the bar a second time.
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.namespace: "qs-control-center"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Timer {
        running: root.warm
        interval: 3000
        onTriggered: root.warm = false
    }

    function toggleDetail(name) {
        detail = detail === name ? "" : name;
    }
    function toggleModule(name) {
        module = module === name ? "" : name;
    }

    // The slow gradient drift runs only while a panel is open.
    onShownChanged: {
        if (shown)
            Ambient.hold();
        else {
            Ambient.release();
            detail = "";
            module = "";
        }
    }
    onDetailChanged: {
        Network.setScanning(detail === "wifi");
        BluetoothState.setScanning(detail === "bluetooth");
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
            contentHeight: content.itemHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            // Hold presses briefly: a scroll/drag that starts on a control (power
            // mode, tiles) must scroll the page, never land as a click on it.
            pressDelay: Theme.pressDelay

            SmoothWheel {
                flick: ccScroll
            }

            // The layout is swapped by Loader, so a style switch is one
            // synchronous teardown/build and the old items are destroyed
            // (no hidden copies keep running).
            Loader {
                id: content

                readonly property real itemHeight: item ? item.implicitHeight : 0

                width: parent.width
                height: itemHeight
                sourceComponent: ({
                        classic: classic,
                        tiles: tiles,
                        pages: pages
                    })[Settings.controlCenterStyle] ?? classic
            }

            Component {
                id: classic

                ClassicLayout {
                    cc: root
                }
            }
            Component {
                id: tiles

                TilesLayout {
                    cc: root
                }
            }
            Component {
                id: pages

                PagesLayout {
                    cc: root
                }
            }
        }
    }
}
