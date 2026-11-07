import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

// Next calendar event: "Standup · 12m" within the chip window (Settings), or
// "Standup · until 10:30" while it runs. Hidden otherwise. Click opens the
// calendar; hover shows the event with a Join button when it has a link.
BarChip {
    id: root

    required property string screenName

    readonly property var ev: CalendarEvents.chipEvent
    // Minutes tick only while the chip is on screen (SystemClock is off otherwise).
    readonly property real t: Math.max(clock.date.getTime(), CalendarEvents.now)
    readonly property bool running: ev !== null && ev.start <= t
    readonly property string countdown: {
        if (!ev)
            return "";
        const m = Math.ceil((ev.start - t) / 60000);
        return m >= 60 ? Math.floor(m / 60) + "h" + (m % 60 ? " " + (m % 60) + "m" : "") : m + "m";
    }
    readonly property string detail: ev ? (running ? "until " + CalendarEvents.fmtTime(ev.end) : countdown) : ""
    readonly property int titleCap: Theme.panelWidth / 2 // content cap, not spacing

    // Collapse (DESIGN.md "Bar: responsive priorities"): title goes at level 2
    // (glyph + countdown), the whole chip at 6 with the input-method chip.
    wanted: ev !== null
    widthAt: l => l >= 6 ? 0 : chipWidth(Theme.icon + Theme.gapInline + (l < 2 ? Math.min(title.width, titleCap) + Theme.gapInline + dot.width + Theme.gapInline : 0) + detailMetrics.width)
    onClicked: Panels.toggle("calendar", screenName)

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
        enabled: root.visible
    }

    TextMetrics {
        id: title

        font: detailLabel.font
        text: root.ev ? root.ev.title : ""
    }

    TextMetrics {
        id: dot

        font: detailLabel.font
        text: "·"
    }

    TextMetrics {
        id: detailMetrics

        font: detailLabel.font
        text: root.detail
    }

    Icon {
        glyph: "󰃭"
        color: root.running ? Theme.primary : Theme.textMuted
    }

    Label {
        visible: root.level < 2
        Layout.maximumWidth: root.titleCap
        text: root.ev?.title ?? ""
    }

    Label {
        visible: root.level < 2
        text: "·"
        color: Theme.textMuted
    }

    Label {
        id: detailLabel

        text: root.detail
        color: root.running ? Theme.primary : Theme.textMuted
    }

    Popover {
        target: root
        shown: root.hovered
        interactive: true // the Join button
        cardWidth: Theme.popoverWidth

        EventCard {
            event: root.ev
        }
    }
}
