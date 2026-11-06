import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Common
import qs.Widgets

// Status-notifier tray icons (Discord, …). Items that merely duplicate the
// shell's own indicators (Wi-Fi, Bluetooth, volume) are hidden.
Row {
    id: root

    required property var bar

    // Substrings of tray ids that our status cluster already covers.
    readonly property var redundant: ["nm-applet", "networkmanager", "blueman", "bluetooth", "pasystray", "pavucontrol", "volume"]

    function isRedundant(item) {
        const id = (item.id || "").toLowerCase();
        return redundant.some(r => id.includes(r));
    }

    spacing: Theme.barInset

    Repeater {
        model: SystemTray.items.values.filter(i => !root.isRedundant(i))

        BarChip {
            id: item

            required property SystemTrayItem modelData

            onClicked: modelData.onlyMenu ? openMenu() : modelData.activate()
            onRightClicked: openMenu()
            onMiddleClicked: modelData.secondaryActivate()
            onScrolled: d => modelData.scroll(d, false)

            function openMenu() {
                if (!modelData.hasMenu)
                    return;
                const p = root.bar.itemPosition(item);
                modelData.display(root.bar, p.x, p.y + item.height + Theme.spaceSm);
            }

            IconImage {
                implicitSize: Theme.icon
                source: item.modelData.icon
            }

            Tooltip {
                target: item
                shown: item.hovered && (item.modelData.tooltipTitle || item.modelData.title) !== ""

                Label {
                    text: item.modelData.tooltipTitle || item.modelData.title
                }
            }
        }
    }
}
