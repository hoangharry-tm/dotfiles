import QtQuick
import Quickshell.Services.SystemTray
import qs.Common
import qs.Widgets

// Status-notifier tray icons (Discord, ...) folded into one "more" chip; the
// icons live in its card. Items that merely duplicate the shell's own
// indicators (Wi-Fi, Bluetooth, volume) are hidden.
BarChip {
    id: root

    // Substrings of tray ids that our status cluster already covers.
    readonly property var redundant: ["nm-applet", "networkmanager", "blueman", "bluetooth", "pasystray", "pavucontrol", "volume"]
    readonly property var items: SystemTray.items.values.filter(i => !isRedundant(i))

    function isRedundant(item) {
        const id = (item.id || "").toLowerCase();
        return redundant.some(r => id.includes(r));
    }

    wanted: items.length > 0
    active: card.open

    Icon {
        glyph: "more_horiz"
        color: Theme.textMuted
    }

    Popover {
        id: card

        target: root
        shown: root.hovered
        interactive: true
        padding: Theme.spaceSm

        Row {
            spacing: Theme.barGap

            Repeater {
                model: root.items

                TrayItem {
                    clear: 0
                }
            }
        }
    }
}
