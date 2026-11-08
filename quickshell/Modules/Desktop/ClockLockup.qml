import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common

// The clock + date lockup: the ONE clock of the shell. The desktop (bottom-
// left, ink from the wallpaper corner), the lock screen and the greeter
// (centred, ink from the whole image) all draw this, so arrival and
// departure read as a single gesture: Inter Light at Theme.textDisplay,
// tabular figures, Theme tracking (via Label), date at textXl.
// Greeter copy: scripts/system-setup.sh SHARED_QML lists this file.
ColumnLayout {
    id: root

    property color ink: Theme.onWallpaper
    property color inkMuted: Theme.onWallpaperMuted
    // Soft shadow opposite to the ink (light ink -> dark shadow), the same
    // rule as Theme.shadowOn but keyed on the ink actually used.
    property color shadowColor: Theme.shadowOn(ink.hslLightness > 0.5 ? 0 : 1)
    property int alignment: Qt.AlignLeft

    spacing: Theme.spaceXs

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    ShadowLabel {
        Layout.alignment: root.alignment
        text: Qt.formatTime(clock.date, "HH:mm")
        font.features: { "tnum": 1 }
        font.pixelSize: Theme.textDisplay
        font.weight: Font.Light
        color: root.ink
        shadowColor: root.shadowColor
    }

    ShadowLabel {
        Layout.alignment: root.alignment
        text: Qt.formatDate(clock.date, "dddd, d MMMM")
        font.pixelSize: Theme.textXl
        color: root.inkMuted
        shadowColor: root.shadowColor
    }
}
