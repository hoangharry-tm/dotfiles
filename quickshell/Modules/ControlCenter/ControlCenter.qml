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

    screen: modelData
    visible: shown
    anchors.top: true
    anchors.right: true
    margins.top: Theme.popoverTop
    margins.right: Theme.edge
    implicitWidth: Theme.panelWidth
    implicitHeight: Math.min(content.implicitHeight + Theme.padSheet * 2, modelData.height - margins.top - Theme.edge)
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.namespace: "qs-control-center"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    function toggleDetail(name) {
        detail = detail === name ? "" : name;
    }

    onShownChanged: {
        if (!shown)
            detail = "";
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
            anchors.fill: parent
            anchors.margins: Theme.padSheet
            contentHeight: content.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: content

                width: parent.width
                spacing: Theme.gapSection

                Header {
                    Layout.fillWidth: true
                    active: root.shown
                }

                // Connectivity: each tile opens its list right below it.
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.gapStack

                    Tile {
                        Layout.fillWidth: true
                        glyph: Network.icon
                        title: Network.wiredConnected ? "Ethernet" : "Wi-Fi"
                        subtitle: Network.label
                        checked: Network.wifiEnabled || Network.wiredConnected
                        expandable: Network.wifi !== null
                        expanded: root.detail === "wifi"
                        onToggled: Network.setWifi(!Network.wifiEnabled)
                        onExpand: root.toggleDetail("wifi")
                    }

                    Loader {
                        Layout.fillWidth: true
                        active: root.detail === "wifi"
                        visible: active
                        sourceComponent: WifiList {}
                    }

                    Tile {
                        Layout.fillWidth: true
                        visible: BluetoothState.available
                        glyph: BluetoothState.icon
                        title: "Bluetooth"
                        subtitle: BluetoothState.label
                        checked: BluetoothState.enabled
                        expandable: true
                        expanded: root.detail === "bluetooth"
                        onToggled: BluetoothState.setEnabled(!BluetoothState.enabled)
                        onExpand: root.toggleDetail("bluetooth")
                    }

                    Loader {
                        Layout.fillWidth: true
                        active: root.detail === "bluetooth"
                        visible: active
                        sourceComponent: BluetoothList {}
                    }
                }

                // Quick toggles
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.gapStack

                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1 // equal widths
                        compact: true
                        glyph: Notifications.dnd ? "󰂛" : "󰂚"
                        title: "Focus"
                        checked: Notifications.dnd
                        onToggled: Notifications.dnd = !Notifications.dnd
                    }

                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        compact: true
                        glyph: KeepAwake.enabled ? "󰅶" : "󰾪"
                        title: "Awake"
                        checked: KeepAwake.enabled
                        onToggled: KeepAwake.enabled = !KeepAwake.enabled
                    }

                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        visible: Audio.source !== null
                        compact: true
                        glyph: Audio.micIcon
                        title: Audio.micMuted ? "Mic off" : "Mic"
                        checked: Audio.micMuted
                        onToggled: Audio.toggleMicMute()
                    }

                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        compact: true
                        glyph: "󰹑"
                        title: "Capture"
                        onToggled: {
                            Panels.close();
                            Quickshell.execDetached(["sh", "-c", "sleep 0.3; niri msg action screenshot"]);
                        }
                    }
                }

                // Display and sound
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.gapStack

                    SliderRow {
                        Layout.fillWidth: true
                        visible: Brightness.available
                        value: Brightness.value
                        glyph: "󰃠"
                        expandable: false
                        onMoved: v => Brightness.set(v)
                    }

                    SliderRow {
                        Layout.fillWidth: true
                        value: Audio.volume
                        glyph: Audio.volumeIcon
                        dimmed: Audio.muted
                        expanded: root.detail === "sound"
                        onMoved: v => Audio.setVolume(v)
                        onIconClicked: Audio.toggleMute()
                        onExpand: root.toggleDetail("sound")
                    }

                    Loader {
                        Layout.fillWidth: true
                        active: root.detail === "sound"
                        visible: active
                        sourceComponent: SoundList {}
                    }
                }

                BatteryCard {
                    Layout.fillWidth: true
                    visible: Power.hasBattery || Power.hasPerformance
                }

                MediaCard {
                    Layout.fillWidth: true
                    visible: Media.active
                    live: root.shown && Media.active
                }

                NotificationList {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
