import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// The Control Center, top to bottom by how often it is reached for:
// connectivity, quick toggles, levels, now playing, then one-line modules that
// expand in place (one at a time; those with nothing to say are absent),
// notifications, and a quiet session footer.
ColumnLayout {
    id: root

    required property var cc

    spacing: Theme.gapSection

    // Wi-Fi and Bluetooth share a row; their lists span the full width below.
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.gapStack

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

    CcCard {
        Layout.fillWidth: true
        cc: root.cc
        kind: "media"
    }

    Group {
        id: modules

        Layout.fillWidth: true

        Module {
            Layout.fillWidth: true
            cc: root.cc
            rowRadius: modules.rowRadius
            kind: "battery"
            glyph: Glyphs.battery()
            title: "Battery"
            summary: Math.round(Power.percent * 100) + "%  ·  " + (Power.timeLabel || "")
        }

        Module {
            Layout.fillWidth: true
            cc: root.cc
            rowRadius: modules.rowRadius
            kind: "weather"
            glyph: Glyphs.weather()
            title: "Weather"
            summary: Weather.tempText + "  ·  " + Weather.label
        }

        Module {
            Layout.fillWidth: true
            cc: root.cc
            rowRadius: modules.rowRadius
            kind: "devices"
            glyph: "devices"
            title: "Devices"
        }

        Module {
            Layout.fillWidth: true
            cc: root.cc
            rowRadius: modules.rowRadius
            kind: "updates"
            glyph: Updates.ok ? "update" : "error"
            title: "Updates"
            summary: Updates.checking ? "Checking…" : !Updates.ok ? "Check failed" : Updates.count + " changes"
        }

        Module {
            Layout.fillWidth: true
            cc: root.cc
            rowRadius: modules.rowRadius
            kind: "backup"
            glyph: BackupStatus.ok ? "backup" : "error"
            title: "Backup"
            summary: BackupStatus.ok ? "Last " + BackupStatus.ago(BackupStatus.last) : "Failed"
        }
    }

    Group {
        id: inbox

        Layout.fillWidth: true

        Module {
            Layout.fillWidth: true
            cc: root.cc
            rowRadius: inbox.rowRadius
            kind: "notifications"
            glyph: "notifications"
            title: "Notifications"
            summary: Notifications.history.length > 0 ? Notifications.history.length + " in history" : "All clear"
        }
    }
}
