import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services

// Five-day outlook: weekday, glyph, label, low / high.
ColumnLayout {
    spacing: Theme.spaceXs

    Repeater {
        model: Weather.daily

        RowLayout {
            required property var modelData
            required property int index

            Layout.fillWidth: true
            spacing: Theme.gapInline

            Label {
                Layout.preferredWidth: Theme.controlLg + Theme.spaceMd
                text: index === 0 ? "Today" : Qt.formatDate(modelData.date, "ddd")
            }

            Icon {
                glyph: Weather.iconFor(modelData.code, true)
                color: Theme.text
            }

            Label {
                Layout.fillWidth: true
                text: Weather.labelFor(modelData.code)
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }

            Label {
                text: Math.round(modelData.min) + "°"
                font.features: { "tnum": 1 }
                color: Theme.textMuted
            }

            Label {
                Layout.preferredWidth: Theme.iconLg + Theme.spaceXs
                horizontalAlignment: Text.AlignRight
                text: Math.round(modelData.max) + "°"
                font.features: { "tnum": 1 }
            }
        }
    }
}
