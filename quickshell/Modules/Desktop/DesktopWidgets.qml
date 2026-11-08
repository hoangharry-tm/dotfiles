import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services

// Wallpaper-layer clock, date, weather and now-playing, bottom-left.
// Click-through (empty input region), no focus, no animation: the only
// update is the SystemClock minute tick (the calendar line moves only at
// event boundaries, see CalendarEvents).
PanelWindow {
    id: root

    required property ShellScreen modelData

    screen: modelData
    anchors.left: true
    anchors.bottom: true
    margins.left: Theme.space2xl * 2
    margins.bottom: Theme.space2xl * 2
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight
    color: "transparent"
    WlrLayershell.namespace: "qs-desktop"
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    mask: passthrough

    Region {
        id: passthrough
    }

    ColumnLayout {
        id: column

        spacing: Theme.spaceXs

        // Same lockup as the lock screen and greeter (one clock).
        ClockLockup {}

        ShadowLabel {
            visible: Weather.ready
            Layout.topMargin: Theme.spaceSm
            Layout.maximumWidth: Theme.launcherWidth
            text: Weather.tempText + "  " + Weather.label + "  ·  " + Weather.city
            font.pixelSize: Theme.textLg
            color: Theme.onWallpaperMuted
        }

        // Hidden unless an event runs now or starts within 12 h (CalendarEvents.line).
        ShadowLabel {
            visible: CalendarEvents.line !== ""
            Layout.maximumWidth: Theme.launcherWidth
            text: CalendarEvents.line
            font.pixelSize: Theme.textMd
            color: Theme.onWallpaperMuted
        }

        ShadowLabel {
            visible: Media.shown && !PowerMode.lowPower // fewer redraws on battery
            Layout.maximumWidth: Theme.launcherWidth
            text: "♪  " + Media.title + (Media.artist ? "  —  " + Media.artist : "")
            font.pixelSize: Theme.textMd
            color: Theme.onWallpaperMuted
        }
    }
}
