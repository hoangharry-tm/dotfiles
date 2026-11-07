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
    implicitHeight: !shown ? 1 : Math.min(content.implicitHeight + Theme.padSheet * 2, modelData.height - margins.top - Theme.edge)
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

    // The slow gradient drift runs only while a panel is open.
    onShownChanged: {
        if (shown)
            Ambient.hold();
        else {
            Ambient.release();
            detail = "";
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
            contentHeight: content.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            // Hold presses briefly: a scroll/drag that starts on a control (power
            // mode, tiles) must scroll the page, never land as a click on it.
            pressDelay: Theme.pressDelay

            SmoothWheel {
                flick: ccScroll
            }

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

                    // Tile and its list share one edge (parent -> child).
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

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
                    }

                    // Tile and its list share one edge (parent -> child).
                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: BluetoothState.available
                        spacing: 0

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
                }

                // Quick toggles: 3 equal columns, so six tiles make two full rows.
                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: Theme.gapStack
                    rowSpacing: Theme.gapStack

                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1 // equal widths
                        compact: true
                        glyph: Notifications.dnd ? "󰂛" : "󰂚"
                        title: "Focus"
                        checked: Notifications.dnd
                        onToggled: Notifications.dnd = !Notifications.dnd
                        onHeld: focusMenu.open = !focusMenu.open
                        z: focusMenu.open ? 1 : 0 // menu draws over the tiles below

                        NotificationFocusMenu {
                            id: focusMenu

                            anchors.top: parent.bottom
                            anchors.topMargin: Theme.spaceXs
                            anchors.left: parent.left
                        }

                        Connections {
                            target: root

                            function onShownChanged() {
                                if (!root.shown)
                                    focusMenu.open = false;
                            }
                        }
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
                        compact: true
                        glyph: Audio.micIcon
                        title: Audio.micMuted ? "Mic off" : "Mic"
                        checked: Audio.micMuted
                        onToggled: Audio.toggleMicMute()
                    }

                    // Tap cycles off -> on -> auto (sunset to sunrise).
                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        compact: true
                        glyph: NightLight.active ? "󰖔" : "󰖙"
                        title: NightLight.mode === "auto" ? "Night auto" : "Night"
                        checked: NightLight.active
                        onToggled: NightLight.cycle()
                    }

                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        compact: true
                        glyph: Recorder.recording ? "󰻃" : "󰑊"
                        title: Recorder.recording ? Recorder.elapsedLabel : "Record"
                        checked: Recorder.recording
                        onToggled: {
                            Panels.close();
                            Recorder.toggle();
                        }
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
                        Layout.leftMargin: Theme.spaceMd // indented under its slider: a child
                        active: root.detail === "sound"
                        visible: active
                        sourceComponent: SoundList {}
                    }
                }

                BatteryCard {
                    Layout.fillWidth: true
                    visible: Power.hasBattery || Power.hasPerformance
                }

                WeatherCard {
                    Layout.fillWidth: true
                    visible: Weather.ready
                }

                BackupRow {
                    Layout.fillWidth: true
                }

                UpdatesRow {
                    Layout.fillWidth: true
                }

                Tile {
                    Layout.fillWidth: true
                    visible: KbdMods.available
                    glyph: "󰌌"
                    title: "Home-row mods"
                    subtitle: KbdMods.on ? "On  \u00b7  Shift+Shift toggles" : "Off"
                    checked: KbdMods.on
                    onToggled: KbdMods.toggle()
                }

                DevicesCard {
                    Layout.fillWidth: true
                    live: root.shown
                }

                MediaCard {
                    Layout.fillWidth: true
                    visible: Media.active
                    live: root.shown && Media.active
                }

                NotificationList {
                    Layout.fillWidth: true
                    visible: root.shown // pauses the cards' minute clock when closed
                }
            }
        }
    }
}
