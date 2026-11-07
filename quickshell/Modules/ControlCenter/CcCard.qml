import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

// One Control Center card by name, built only while it has something to
// show. Every layout places cards through this, so the cards, their
// visibility rules and their services exist once (no per-layout copies).
//   kind: battery | weather | backup | updates | kbd | devices | media | notifications
Loader {
    id: root

    required property var cc
    property string kind: ""

    readonly property bool wanted: ({
            battery: Power.hasBattery || Power.hasPerformance,
            weather: Weather.ready,
            backup: true,
            updates: true,
            kbd: KbdMods.available,
            devices: Devices.any,
            media: Media.active,
            notifications: cc.shown // pauses the cards' minute clock when closed
        })[kind] === true

    active: wanted
    visible: wanted
    sourceComponent: ({
            battery: battery,
            weather: weather,
            backup: backup,
            updates: updates,
            kbd: kbd,
            devices: devices,
            media: media,
            notifications: notifications
        })[kind]

    // A card shown under a header tile fuses with it: flat top corners.
    property bool attach: false
    onLoaded: if (attach && item.attached !== undefined)
        item.attached = true

    Component {
        id: battery

        BatteryCard {}
    }
    Component {
        id: weather

        WeatherCard {}
    }
    Component {
        id: backup

        BackupRow {}
    }
    Component {
        id: updates

        UpdatesRow {}
    }
    Component {
        id: kbd

        Tile {
            glyph: "󰌌"
            title: "Home-row mods"
            subtitle: KbdMods.on ? "On  ·  Shift+Shift toggles" : "Off"
            checked: KbdMods.on
            onToggled: KbdMods.toggle()
        }
    }
    Component {
        id: devices

        DevicesCard {
            live: root.cc.shown
        }
    }
    Component {
        id: media

        MediaCard {
            live: root.cc.shown && Media.active
        }
    }
    Component {
        id: notifications

        NotificationList {}
    }
}
