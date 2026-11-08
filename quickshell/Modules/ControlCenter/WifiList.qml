import QtQuick
import qs.Services

// Nearby networks. Tap to join; secured unknown networks ask for the
// password inline. Right-click a saved network to forget it.
DetailList {
    id: root

    property var asking: null       // network waiting for a password

    readonly property var shown: Network.networks.slice(0, 10)
    readonly property var known: shown.filter(n => n.known || n.connected)
    readonly property var others: shown.filter(n => !(n.known || n.connected))

    title: "Wi-Fi"
    actionGlyph: "refresh"
    actionActive: Network.scanning
    actionTip: Network.scanning ? "Scanning, " + Network.scanMinutesLeft + " min left. Click to stop" : "Refresh"
    count: shown.length
    emptyText: Network.wifiEnabled ? (Network.scanning ? "Searching…" : "No networks found") : "Wi-Fi is off"
    onAction: Network.scanning ? Network.stopScan() : Network.scanFor(Settings.scanWindow * 1000)

    ListBlock {
        count: root.known.length
        heading: root.others.length > 0 ? "Known" : ""

        Repeater {
            model: root.known

            NetworkRow {
                asking: root.asking
                onAsk: n => root.asking = n
            }
        }
    }

    ListBlock {
        count: root.others.length
        heading: root.known.length > 0 ? "Other networks" : ""

        Repeater {
            model: root.others

            NetworkRow {
                asking: root.asking
                onAsk: n => root.asking = n
            }
        }
    }
}
