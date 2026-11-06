import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Wi-Fi · Bluetooth · Volume · Battery (+ Do Not Disturb) as one target that
// opens the Control Center, which also hosts notifications. An accent dot
// marks unread notifications. Scroll = volume, middle = mute, right = DND.
BarChip {
    id: root

    required property string screenName

    // Only show Bluetooth when it's doing something; quiet otherwise.
    readonly property bool showBluetooth: BluetoothState.available && BluetoothState.connected.length > 0
    readonly property bool unread: Notifications.history.length > 0 && !Notifications.dnd
    readonly property var batteryDevices: BluetoothState.connected.filter(d => d.batteryAvailable)

    active: Panels.isOpen("control", screenName)
    onClicked: Panels.toggle("control", screenName)
    onMiddleClicked: Audio.toggleMute()
    onRightClicked: Notifications.dnd = !Notifications.dnd

    spacing: Theme.spaceMd

    // Collapse: only the battery percentage goes (level 9); the icons stay.
    // Computed from the data, not implicitWidth, which changes with `level`.
    readonly property int pctLevel: 9
    readonly property var parts: [true, showBluetooth, true, Notifications.dnd, PowerMode.lowPower, Power.hasBattery]
    widthAt: l => {
        const n = parts.filter(Boolean).length;
        const pct = Power.hasBattery && l < pctLevel ? Theme.spaceXs + pctLabel.implicitWidth : 0;
        return chipWidth(n * Theme.icon + (n - 1) * Theme.spaceMd + pct);
    }

    Icon {
        glyph: Network.icon
        color: Network.active || Network.wiredConnected ? Theme.text : Theme.textMuted
    }

    Icon {
        visible: root.showBluetooth
        glyph: BluetoothState.icon
    }

    Icon {
        glyph: Audio.volumeIcon
        color: Audio.muted ? Theme.textMuted : Theme.text
    }

    Icon {
        visible: Notifications.dnd
        glyph: "󰂛"
        color: Theme.textMuted
    }

    Icon {
        visible: PowerMode.lowPower
        glyph: "󰌪" // leaf: low power is on
        color: Theme.tertiary
    }

    RowLayout {
        visible: Power.hasBattery
        spacing: Theme.spaceXs

        Icon {
            glyph: Power.icon
            color: Power.percent < 0.15 && !Power.charging ? Theme.error : Theme.text
        }

        Label {
            id: pctLabel

            visible: root.level < root.pctLevel
            text: Math.round(Power.percent * 100) + "%"
        }
    }

    Rectangle {
        visible: root.unread
        x: parent.width - width - Theme.spaceXs
        y: Theme.spaceXs
        width: Theme.spaceSm
        height: Theme.spaceSm
        radius: Theme.radiusFull
        color: Theme.primary
        border.width: 2
        border.color: Theme.surface
    }

    Popover {
        target: root
        shown: root.hovered && !root.active
        cardWidth: Theme.popoverWidth

        InfoRow {
            glyph: Network.icon
            label: "Network"
            value: Network.label
        }

        InfoRow {
            visible: BluetoothState.available
            glyph: BluetoothState.icon
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
            glyph: Audio.volumeIcon
            label: "Volume"
            value: Audio.muted ? "Muted" : Math.round(Audio.volume * 100) + "%"
        }

        InfoRow {
            visible: Power.hasBattery
            glyph: Power.icon
            label: "Battery"
            value: Math.round(Power.percent * 100) + "%" + (Power.timeLabel ? "  \u00b7  " + Power.timeLabel : "")
            valueColor: Power.percent < 0.15 && !Power.charging ? Theme.error : Theme.text
        }

        InfoRow {
            glyph: Notifications.dnd ? "󰂛" : "󰂚"
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
