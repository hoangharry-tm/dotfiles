import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// "Classic": one scrolling column, connectivity first, cards below.
ColumnLayout {
    id: root

    required property var cc

    spacing: Theme.gapSection

    Header {
        Layout.fillWidth: true
        active: root.cc.shown
    }

    // Connectivity: each tile opens its list right below it.
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.gapStack

        WifiBlock {
            Layout.fillWidth: true
            cc: root.cc
        }

        BluetoothBlock {
            Layout.fillWidth: true
            cc: root.cc
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
        kind: "battery"
    }
    CcCard {
        Layout.fillWidth: true
        cc: root.cc
        kind: "weather"
    }
    CcCard {
        Layout.fillWidth: true
        cc: root.cc
        kind: "backup"
    }
    CcCard {
        Layout.fillWidth: true
        cc: root.cc
        kind: "updates"
    }
    CcCard {
        Layout.fillWidth: true
        cc: root.cc
        kind: "kbd"
    }
    CcCard {
        Layout.fillWidth: true
        cc: root.cc
        kind: "devices"
    }
    CcCard {
        Layout.fillWidth: true
        cc: root.cc
        kind: "media"
    }
    CcCard {
        Layout.fillWidth: true
        cc: root.cc
        kind: "notifications"
    }
}
