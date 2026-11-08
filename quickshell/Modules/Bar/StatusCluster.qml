import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Wi-Fi · Volume · Battery (+ Bluetooth when connected, Do Not Disturb and
// low power when on) as one target that opens the Control Center, which also
// hosts notifications. The battery
// percentage shows only when low. Scroll = volume, middle = mute, right = DND.
BarChip {
    id: root

    required property string screenName

    // Only show Bluetooth when it's doing something; quiet otherwise.
    readonly property bool showBluetooth: BluetoothState.available && BluetoothState.connected.length > 0
    readonly property var batteryDevices: BluetoothState.connected.filter(d => d.batteryAvailable)

    active: Panels.isOpen("control", screenName)
    onClicked: Panels.toggle("control", screenName)
    onMiddleClicked: Audio.toggleMute()
    onRightClicked: Notifications.dnd = !Notifications.dnd

    spacing: Theme.spaceMd

    // Material Symbols names for the services' state (the services return
    // legacy Nerd codepoints).
    readonly property bool low: Power.hasBattery && Power.percent < 0.2 && !Power.charging
    readonly property string wifiIcon: Network.wiredConnected ? "lan" : !Network.wifiEnabled || !Network.active ? "wifi_off" : Network.strength > 0.66 ? "wifi" : Network.strength > 0.33 ? "wifi_2_bar" : "wifi_1_bar"
    readonly property string btIcon: !BluetoothState.enabled ? "bluetooth_disabled" : BluetoothState.connected.length ? "bluetooth_connected" : "bluetooth"
    readonly property string volumeSymbol: Audio.muted ? "volume_off" : Audio.volume < 0.01 ? "volume_mute" : Audio.volume < 0.5 ? "volume_down" : "volume_up"
    readonly property string batterySymbol: Power.charging ? "battery_charging_full" : Power.percent >= 0.95 ? "battery_full" : "battery_" + Math.min(6, Math.floor(Power.percent * 7)) + "_bar"

    // Collapse: only the battery percentage goes (level 5); the icons stay.
    // Computed from the data, not implicitWidth, which changes with `level`.
    readonly property int pctLevel: 5
    readonly property var parts: [true, showBluetooth, true, Notifications.dnd, PowerMode.lowPower, Power.hasBattery]
    widthAt: l => {
        const n = parts.filter(Boolean).length;
        const pct = low && l < pctLevel ? Theme.spaceXs + pctLabel.implicitWidth : 0;
        return chipWidth(n * Theme.icon + (n - 1) * Theme.spaceMd + pct);
    }

    Icon {
        glyph: root.wifiIcon
        color: Network.active || Network.wiredConnected ? Theme.text : Theme.textMuted
    }

    Icon {
        visible: root.showBluetooth
        glyph: root.btIcon
    }

    Icon {
        glyph: root.volumeSymbol
        color: Audio.muted ? Theme.textMuted : Theme.text
    }

    Icon {
        visible: Notifications.dnd
        glyph: "notifications_off"
        color: Theme.textMuted
    }

    Icon {
        visible: PowerMode.lowPower
        glyph: "eco" // low power is on
        color: Theme.textMuted
    }

    RowLayout {
        visible: Power.hasBattery
        spacing: Theme.spaceXs

        Icon {
            glyph: root.batterySymbol
            color: root.low ? Theme.error : Theme.text
        }

        Label {
            id: pctLabel

            visible: root.low && root.level < root.pctLevel
            text: Math.round(Power.percent * 100) + "%"
            color: Theme.error
            font.features: { "tnum": 1 }
        }
    }

    Popover {
        target: root
        shown: root.hovered && !root.active
        cardWidth: Theme.popoverWidth

        InfoRow {
            glyph: root.wifiIcon
            label: "Network"
            value: Network.label
        }

        InfoRow {
            visible: BluetoothState.available
            glyph: root.btIcon
            label: "Bluetooth"
            value: BluetoothState.label
        }

        Repeater {
            model: root.batteryDevices

            InfoRow {
                required property var modelData

                Layout.leftMargin: Theme.icon + Theme.gapInline // under the label, not the icon
                label: BluetoothState.nameOf(modelData)
                value: Math.round(modelData.battery * 100) + "%"
                valueColor: Theme.textMuted
            }
        }

        InfoRow {
            glyph: root.volumeSymbol
            label: "Volume"
            value: Audio.muted ? "Muted" : Math.round(Audio.volume * 100) + "%"
        }

        InfoRow {
            visible: Power.hasBattery
            glyph: root.batterySymbol
            label: "Battery"
            value: Math.round(Power.percent * 100) + "%" + (Power.timeLabel ? "  \u00b7  " + Power.timeLabel : "")
            valueColor: root.low ? Theme.error : Theme.text
        }

        InfoRow {
            glyph: Notifications.dnd ? "notifications_off" : "notifications"
            label: "Notifications"
            value: Notifications.dnd ? "Do Not Disturb" : Notifications.history.length > 0 ? Notifications.history.length + " unread" : "None"
        }

        Label {
            Layout.topMargin: Theme.spaceXs
            text: "Right-click toggles Do Not Disturb"
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }
    }
}
