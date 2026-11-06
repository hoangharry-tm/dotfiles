import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

// Wi-Fi · Bluetooth · Volume · Battery (+ Do Not Disturb) as one target that
// opens the Control Center, which also hosts notifications. An accent dot
// marks unread notifications. Scroll = volume, middle = mute, right = DND.
Clickable {
    id: root

    required property string screenName

    // Only show Bluetooth when it's doing something; quiet otherwise.
    readonly property bool showBluetooth: BluetoothState.available && BluetoothState.connected.length > 0
    readonly property bool unread: Notifications.history.length > 0 && !Notifications.dnd
    readonly property var batteryDevices: BluetoothState.connected.filter(d => d.batteryAvailable)

    implicitWidth: row.implicitWidth + 18
    implicitHeight: 26
    active: Panels.isOpen("control", screenName)
    onClicked: Panels.toggle("control", screenName)
    onMiddleClicked: Audio.toggleMute()
    onRightClicked: Notifications.dnd = !Notifications.dnd
    onScrolled: d => Audio.setVolume(Audio.volume + (d > 0 ? 0.05 : -0.05))

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 11

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

        Row {
            visible: Power.hasBattery
            spacing: 5

            Icon {
                glyph: Power.icon
                color: Power.percent < 0.15 && !Power.charging ? Theme.error : Theme.text
            }

            Label {
                text: Math.round(Power.percent * 100) + "%"
                font.pixelSize: Theme.textSm
            }
        }
    }

    Rectangle {
        visible: root.unread
        x: parent.width - 7
        y: 2
        width: 7
        height: 7
        radius: 3.5
        color: Theme.primary
        border.width: 1.5
        border.color: Theme.surface
    }

    Tooltip {
        target: root
        shown: root.hovered && !root.active

        Label {
            text: "Wi-Fi       " + Network.label
        }

        Label {
            visible: BluetoothState.available
            text: "Bluetooth   " + BluetoothState.label
        }

        Repeater {
            model: root.batteryDevices

            Label {
                required property var modelData

                text: "  " + BluetoothState.nameOf(modelData) + "  " + Math.round(modelData.battery * 100) + "%"
                color: Theme.textMuted
                font.pixelSize: Theme.textSm
            }
        }

        Label {
            text: "Volume      " + (Audio.muted ? "Muted" : Math.round(Audio.volume * 100) + "%")
        }

        Label {
            visible: Power.hasBattery
            text: "Battery     " + Math.round(Power.percent * 100) + "%" + (Power.timeLabel ? " · " + Power.timeLabel : "")
        }

        Label {
            text: Notifications.dnd ? "Do Not Disturb" : Notifications.history.length + " notifications"
            color: Theme.textMuted
        }

        Label {
            text: "Right-click: Do Not Disturb"
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }
    }
}
