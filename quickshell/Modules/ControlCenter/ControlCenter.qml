import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import qs.Common
import qs.Services
import qs.Widgets

// Apple-style Control Center under the bar's right end.
PanelWindow {
    id: root

    required property ShellScreen modelData
    readonly property bool shown: Panels.isOpen("control", modelData.name)

    // Which detail list is expanded: "", "wifi", "bluetooth", "output", "input"
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
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Theme.gapStack
                    rowSpacing: Theme.gapStack

                    Tile {
                        Layout.fillWidth: true
                        glyph: Network.wiredConnected ? "󰈀" : Network.wifiEnabled ? "󰤨" : "󰤮"
                        title: Network.wiredConnected ? "Ethernet" : "Wi-Fi"
                        subtitle: Network.label
                        checked: Network.wifiEnabled || Network.wiredConnected
                        expandable: Network.wifi !== null
                        expanded: root.detail === "wifi"
                        onToggled: Network.setWifi(!Network.wifiEnabled)
                        onExpand: root.detail = root.detail === "wifi" ? "" : "wifi"
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
                        onExpand: root.detail = root.detail === "bluetooth" ? "" : "bluetooth"
                    }

                    Tile {
                        Layout.fillWidth: true
                        glyph: Notifications.dnd ? "󰂛" : "󰂚"
                        title: "Focus"
                        subtitle: Notifications.dnd ? "Do not disturb" : "Off"
                        checked: Notifications.dnd
                        onToggled: Notifications.dnd = !Notifications.dnd
                    }

                    Tile {
                        Layout.fillWidth: true
                        readonly property var modes: [PowerProfile.PowerSaver, PowerProfile.Balanced].concat(Power.hasPerformance ? [PowerProfile.Performance] : [])
                        glyph: Power.profile === PowerProfile.PowerSaver ? "󰌪" : Power.profile === PowerProfile.Performance ? "󰓅" : "󰾅"
                        title: "Power mode"
                        subtitle: PowerProfile.toString(Power.profile).replace(/([a-z])([A-Z])/g, "$1 $2")
                        checked: Power.profile !== PowerProfile.Balanced
                        onToggled: Power.setProfile(modes[(modes.indexOf(Power.profile) + 1) % modes.length])
                    }
                }

                // Expanded details for a tile or a slider's device picker
                Loader {
                    Layout.fillWidth: true
                    active: root.detail !== ""
                    visible: active
                    sourceComponent: root.detail === "wifi" ? wifiList : root.detail === "bluetooth" ? bluetoothList : audioList
                }

                Section {
                    Layout.fillWidth: true

                    SliderRow {
                        Layout.fillWidth: true
                        value: Audio.volume
                        glyph: Audio.volumeIcon
                        dimmed: Audio.muted
                        expanded: root.detail === "output"
                        onMoved: v => Audio.setVolume(v)
                        onIconClicked: Audio.toggleMute()
                        onExpand: root.detail = root.detail === "output" ? "" : "output"
                    }

                    SliderRow {
                        Layout.fillWidth: true
                        visible: Audio.source !== null
                        value: Audio.micVolume
                        glyph: Audio.micIcon
                        dimmed: Audio.micMuted
                        expanded: root.detail === "input"
                        onMoved: v => Audio.setMicVolume(v)
                        onIconClicked: Audio.toggleMicMute()
                        onExpand: root.detail = root.detail === "input" ? "" : "input"
                    }

                    SliderRow {
                        Layout.fillWidth: true
                        visible: Brightness.available
                        value: Brightness.value
                        glyph: "󰃠"
                        expandable: false
                        onMoved: v => Brightness.set(v)
                    }
                }

                MediaCard {
                    Layout.fillWidth: true
                    visible: Media.active
                }

                NotificationList {
                    Layout.fillWidth: true
                }
            }
        }
    }

    Component {
        id: wifiList

        WifiList {}
    }

    Component {
        id: bluetoothList

        BluetoothList {}
    }

    Component {
        id: audioList

        AudioList {
            output: root.detail === "output"
        }
    }
}
