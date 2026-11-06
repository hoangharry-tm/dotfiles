import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

// Focus-timer ring and mm:ss, only while the timer is running or paused (dimmed
// and static). Click plays or pauses; hover opens the timer card.
BarChip {
    id: root

    // Collapse: mm:ss goes from level 5, the whole chip from 8 (the tray folds
    // first at 7, so the ring outlives it). The Control Center still has it.
    readonly property bool showText: level < 5

    wanted: FocusTimer.active
    widthAt: l => l >= 8 ? 0 : chipWidth(Theme.icon + (l < 5 ? Theme.gapInline + clock.implicitWidth : 0))
    onClicked: FocusTimer.toggle()

    // Tick registration (one count per bar, so several screens add up): seconds
    // only while mm:ss is on screen, else the slow ring tick. A paused chip is
    // static; the tick timer itself only runs while the timer does. The open
    // card registers its own seconds.
    readonly property bool needSeconds: visible && showText
    onNeedSecondsChanged: FocusTimer.secWatchers += needSeconds ? 1 : -1
    onVisibleChanged: FocusTimer.ringWatchers += visible ? 1 : -1
    Component.onCompleted: {
        if (visible)
            FocusTimer.ringWatchers++;
        if (needSeconds)
            FocusTimer.secWatchers++;
    }
    Component.onDestruction: {
        if (visible)
            FocusTimer.ringWatchers--;
        if (needSeconds)
            FocusTimer.secWatchers--;
    }

    ProgressRing {
        implicitWidth: Theme.icon
        implicitHeight: Theme.icon
        value: FocusTimer.fraction
        opacity: FocusTimer.running ? 1 : 0.5 // paused reads as dimmed
    }

    Label {
        id: clock

        visible: root.showText
        text: FocusTimer.clockText
        font.pixelSize: Theme.textSm
        font.features: { "tnum": 1 }
        color: FocusTimer.running ? Theme.text : Theme.textMuted
    }

    Popover {
        target: root
        shown: root.hovered
        interactive: true

        TimerCard {}
    }
}
