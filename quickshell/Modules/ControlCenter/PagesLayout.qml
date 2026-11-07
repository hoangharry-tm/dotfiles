import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// "Pages": a calm one-screen-at-a-time layout. A segmented switcher under
// the header picks Home (connect, toggles, levels, media), System (power,
// weather, upkeep) or Inbox (notifications). Only the current page is
// built, so the sheet is short and cheap, and rarely needs scrolling.
ColumnLayout {
    id: root

    required property var cc

    spacing: Theme.gapSection

    Header {
        Layout.fillWidth: true
        active: root.cc.shown
    }

    Segmented {
        Layout.fillWidth: true
        model: [
            { glyph: "󰕮", label: "Home", value: "home" },
            { glyph: "󰍛", label: "System", value: "system" },
            { glyph: "󰂚", label: "Inbox", value: "inbox" }
        ]
        current: root.cc.page
        onPicked: v => root.cc.page = v
    }

    Loader {
        Layout.fillWidth: true
        sourceComponent: ({
                home: home,
                system: system,
                inbox: inbox
            })[root.cc.page] ?? home
    }

    Component {
        id: home

        ColumnLayout {
            spacing: Theme.gapSection

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
                kind: "media"
            }
        }
    }

    Component {
        id: system

        ColumnLayout {
            spacing: Theme.gapSection

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
                kind: "updates"
            }
            CcCard {
                Layout.fillWidth: true
                cc: root.cc
                kind: "backup"
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
        }
    }

    Component {
        id: inbox

        CcCard {
            cc: root.cc
            kind: "notifications"
        }
    }
}
