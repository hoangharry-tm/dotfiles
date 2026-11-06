import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// A single quiet glyph; tints when the machine is busy. Hover for live graphs.
BarChip {
    id: root

    // Collapse: hidden from level 8 (hover card is a secondary view).
    widthAt: l => l >= 8 ? 0 : implicitWidth

    readonly property bool busy: System.cpu > 0.8 || System.mem > 0.9 || System.temp > 85

    Icon {
        glyph: "󰍛"
        color: root.busy ? Theme.tertiary : Theme.textMuted
    }

    // `ps` and the extra reads run only while the card is open.
    Binding {
        target: System
        property: "tracking"
        value: card.open
    }

    Popover {
        id: card

        target: root
        shown: root.hovered
        cardWidth: Theme.popoverWidth

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.gapInline

            Icon {
                glyph: "󰍛"
                color: Theme.primary
            }

            Label {
                Layout.fillWidth: true
                text: "System"
                font.weight: Font.DemiBold
            }

            Label {
                text: "Up " + System.formatUptime(System.uptime)
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }
        }

        StatRow {
            Layout.topMargin: Theme.spaceXs
            name: "CPU  ·  " + Math.round(System.temp) + "°C"
            value: Math.round(System.cpu * 100) + "%"
            history: System.cpuHistory
        }

        StatRow {
            name: "Memory"
            value: System.memUsed.toFixed(1) + " / " + System.memTotal.toFixed(1) + " GiB"
            history: System.memHistory
            color: Theme.secondary
        }

        StatRow {
            name: "Network  ·  ↑ " + System.formatRate(System.netUp)
            value: "↓ " + System.formatRate(System.netDown)
            history: System.netDownHistory
            maxValue: 0
            color: Theme.tertiary
        }

        InfoRow {
            Layout.topMargin: Theme.spaceXs
            label: "Load"
            value: System.load.toFixed(2)
            mono: true
        }

        InfoRow {
            visible: System.topName !== ""
            label: "Heaviest"
            value: System.topName + "  " + System.topMem.toFixed(1) + " GiB"
            mono: true
        }
    }
}
