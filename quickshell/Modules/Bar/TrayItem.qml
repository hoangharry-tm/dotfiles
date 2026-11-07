import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Common
import qs.Widgets

// One status-notifier icon; used inline in the bar and inside the overflow card.
BarChip {
    id: item

    required property SystemTrayItem modelData
    // Menu offset below the chip: the bar inset + popover gap in the bar,
    // none inside the overflow card (there is no bar edge to clear).
    property real clear: Theme.barInset + Theme.popoverGap
    readonly property string tip: modelData.tooltipTitle || modelData.title

    onClicked: modelData.onlyMenu ? openMenu() : modelData.activate()
    onRightClicked: openMenu()
    onMiddleClicked: modelData.secondaryActivate()
    wheelEnabled: true
    onScrolled: d => modelData.scroll(d, false)

    function openMenu() {
        const win = QsWindow.window;
        if (!modelData.hasMenu || !win)
            return;
        const p = win.itemPosition(item);
        modelData.display(win, p.x, p.y + item.height + clear);
    }

    IconImage {
        implicitSize: Theme.icon
        source: item.modelData.icon
    }

    Popover {
        target: item
        shown: item.hovered && item.tip !== ""
        padding: Theme.padControl

        Label {
            text: item.tip
        }

        Label {
            visible: item.modelData.tooltipDescription !== ""
            text: item.modelData.tooltipDescription
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }
    }
}
