import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Weather glyph + temperature; hover for conditions, next 12 h and 5 days.
BarChip {
    id: root

    // Collapse: temperature text from level 1, whole chip from 5 (the Control
    // Center still shows the weather).
    wanted: Weather.ready
    widthAt: l => l >= 5 ? 0 : chipWidth(Theme.icon + (l < 1 ? Theme.gapInline + temp.implicitWidth : 0))
    onClicked: Weather.refresh()

    Icon {
        glyph: Weather.glyph
        color: Theme.primary
    }

    Label {
        id: temp

        visible: root.level < 1
        text: Weather.tempText
        color: Theme.textMuted
    }

    Popover {
        target: root
        shown: root.hovered
        cardWidth: Theme.popoverWidth

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spaceMd

            Icon {
                glyph: Weather.glyph
                size: Theme.iconHero
                color: Theme.primary
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceXs

                Label {
                    text: Weather.tempText + "  " + Weather.label
                    font.pixelSize: Theme.textXl
                    font.weight: Font.DemiBold
                }

                Label {
                    text: Weather.city + "  ·  feels " + Math.round(Weather.feels) + "°"
                    color: Theme.textMuted
                    font.pixelSize: Theme.textXs
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: Math.round(Weather.humidity) + "% humidity  ·  " + Math.round(Weather.wind) + " km/h wind  ·  ↑ " + Weather.sunrise + "  ↓ " + Weather.sunset
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }

        HourlyChart {
            Layout.fillWidth: true
        }

        ForecastList {
            Layout.fillWidth: true
        }
    }
}
