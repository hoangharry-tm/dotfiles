import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

// A single quiet glyph; tints when the machine is busy. Hover for live graphs.
Clickable {
    id: root

    readonly property bool busy: System.cpu > 0.8 || System.mem > 0.9 || System.temp > 85

    implicitWidth: 30
    implicitHeight: 26

    Icon {
        anchors.centerIn: parent
        glyph: "󰍛"
        color: root.busy ? Theme.tertiary : Theme.textMuted
    }

    Tooltip {
        target: root
        shown: root.hovered

        StatRow {
            name: "CPU · " + Math.round(System.temp) + "°C"
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
            name: "Network"
            value: "↓ " + System.formatRate(System.netDown) + "   ↑ " + System.formatRate(System.netUp)
            history: System.netDownHistory
            maxValue: 0
            color: Theme.tertiary
        }
    }
}
