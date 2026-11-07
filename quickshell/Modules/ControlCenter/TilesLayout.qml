import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// "Tiles": a macOS-style modular grid. Connectivity sits side by side,
// toggles and sliders follow, and everything else is a one-line module that
// expands in place (one at a time), so the sheet is short until asked.
ColumnLayout {
    id: root

    required property var cc

    spacing: Theme.gapSection

    Header {
        Layout.fillWidth: true
        active: root.cc.shown
    }

    // Now playing leads: the card with the most to say, only while playing.
    CcCard {
        Layout.fillWidth: true
        cc: root.cc
        kind: "media"
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.gapStack

        // Wi-Fi and Bluetooth share a row; their lists span the full width below.
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.gapStack

            WifiBlock {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.alignment: Qt.AlignTop
                cc: root.cc
                list: false
            }

            BluetoothBlock {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.alignment: Qt.AlignTop
                cc: root.cc
                list: false
            }
        }

        Loader {
            Layout.fillWidth: true
            active: root.cc.detail === "wifi"
            visible: active
            sourceComponent: WifiList {}
        }

        Loader {
            Layout.fillWidth: true
            active: root.cc.detail === "bluetooth"
            visible: active
            sourceComponent: BluetoothList {}
        }
    }

    QuickToggles {
        Layout.fillWidth: true
        cc: root.cc
    }

    LevelSliders {
        Layout.fillWidth: true
        cc: root.cc
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.gapStack

        Module {
            Layout.fillWidth: true
            visible: Power.hasBattery || Power.hasPerformance
            cc: root.cc
            kind: "battery"
            glyph: Power.icon
            title: "Battery"
            summary: Math.round(Power.percent * 100) + "%  ·  " + (Power.timeLabel || "")
        }

        Module {
            Layout.fillWidth: true
            visible: Weather.ready
            cc: root.cc
            kind: "weather"
            glyph: Weather.glyph
            title: "Weather"
            summary: Weather.tempText + "  \u00b7  " + Weather.label
        }

        Module {
            Layout.fillWidth: true
            cc: root.cc
            kind: "updates"
            glyph: "󰚰"
            title: "Updates"
        }

        Module {
            Layout.fillWidth: true
            cc: root.cc
            kind: "backup"
            glyph: "󰁯"
            title: "Backup"
        }

        Module {
            Layout.fillWidth: true
            visible: Devices.any
            cc: root.cc
            kind: "devices"
            glyph: "󰄜"
            title: "Devices"
        }

        CcCard {
            Layout.fillWidth: true
            cc: root.cc
            kind: "kbd"
        }
    }

    Module {
        Layout.fillWidth: true
        cc: root.cc
        kind: "notifications"
        glyph: "󰂚"
        title: "Notifications"
        summary: Notifications.history.length > 0 ? Notifications.history.length + " in history" : "All clear"
    }
}
