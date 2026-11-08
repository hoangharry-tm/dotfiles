import QtQuick
import qs.Common
import qs.Services

// One Control Center card by name, built only while it has something to
// show. The layout places cards through this, so the cards, their
// visibility rules and their services exist once.
//   kind: battery | weather | backup | updates | devices | media | notifications
Loader {
    id: root

    required property var cc
    property string kind: ""

    readonly property bool wanted: ({
            battery: Power.hasBattery || Power.hasPerformance,
            weather: Weather.ready,
            backup: BackupStatus.attention,
            updates: Updates.count > 0 || Updates.checking || (Updates.known && !Updates.ok),
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
            devices: devices,
            media: media,
            notifications: notifications
        })[kind]

    // A card opened under a row of a Group becomes its L2 well (Section.flat).
    property bool flat: false
    property real wellRadius: Theme.radiusSm // the group's rowRadius
    onLoaded: if (flat && item.flat !== undefined) {
        item.flat = true;
        item.radius = wellRadius;
    }

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
