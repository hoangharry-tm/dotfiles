import QtQuick
import Quickshell.Services.SystemTray
import qs.Common
import qs.Widgets

// Status-notifier tray icons (Discord, …). Items that merely duplicate the
// shell's own indicators (Wi-Fi, Bluetooth, volume) are hidden. Collapse
// (level 7+): all icons fold into one "…" chip whose card holds them.
Row {
    id: root

    property int level: 0

    // Substrings of tray ids that our status cluster already covers.
    readonly property var redundant: ["nm-applet", "networkmanager", "blueman", "bluetooth", "pasystray", "pavucontrol", "volume"]
    readonly property var items: SystemTray.items.values.filter(i => !isRedundant(i))
    readonly property int overflowFrom: 7
    readonly property bool folded: level >= overflowFrom

    // Responsive hooks (see ResponsiveRow). An icon-only chip is
    // max(control, icon + 2 * padControl) wide, as BarChip computes.
    readonly property bool wanted: items.length > 0
    readonly property real chipW: Math.max(Theme.control, Theme.icon + Theme.padControl * 2)
    readonly property var widthAt: l => l >= overflowFrom ? chipW : items.length * chipW + (items.length - 1) * spacing

    function isRedundant(item) {
        const id = (item.id || "").toLowerCase();
        return redundant.some(r => id.includes(r));
    }

    spacing: Theme.barGap
    visible: wanted

    Repeater {
        model: root.folded ? [] : root.items

        TrayItem {}
    }

    BarChip {
        id: more

        visible: root.folded
        active: card.open

        Icon {
            glyph: "󰇘"
            color: Theme.textMuted
        }

        Popover {
            id: card

            target: more
            shown: more.hovered
            interactive: true
            padding: Theme.spaceSm

            Row {
                spacing: Theme.barGap

                Repeater {
                    model: root.folded ? root.items : []

                    TrayItem {
                        clear: 0
                    }
                }
            }
        }
    }
}
