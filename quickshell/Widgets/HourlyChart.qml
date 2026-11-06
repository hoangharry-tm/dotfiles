import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services

// Temperature line for the next 12 h with start/end hour and range labels.
ColumnLayout {
    readonly property var temps: Weather.hourly.map(h => h.temp)
    readonly property real lo: temps.length ? Math.min(...temps) : 0
    readonly property real hi: temps.length ? Math.max(...temps) : 0

    spacing: Theme.spaceXs

    Sparkline {
        Layout.fillWidth: true
        implicitHeight: Theme.controlLg
        // Sparkline scales from 0; shift so the line spans the full height.
        values: temps.map(t => t - lo + 0.5)
        maxValue: hi - lo + 1
    }

    RowLayout {
        Layout.fillWidth: true

        Label {
            Layout.fillWidth: true
            text: Weather.hourly.length ? Qt.formatTime(Weather.hourly[0].time, "HH:mm") : ""
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }

        Label {
            text: Math.round(lo) + "° – " + Math.round(hi) + "°"
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }
    }
}
