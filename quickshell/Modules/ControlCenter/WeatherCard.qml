import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Current conditions, a 12 h trend and the 5-day outlook. Tap to refresh.
Section {
    id: root

    Clickable {
        Layout.fillWidth: true
        implicitHeight: head.implicitHeight
        onClicked: Weather.refresh()

        RowLayout {
            id: head

            anchors.fill: parent
            spacing: Theme.gapInline

            Icon {
                glyph: Weather.glyph
                size: Theme.iconXl
                color: Theme.primary
            }

            Label {
                text: Weather.tempText
                font.pixelSize: Theme.textXl
                font.weight: Font.DemiBold
            }

            Label {
                Layout.fillWidth: true
                text: Weather.label
                color: Theme.textMuted
            }

            Label {
                text: Weather.city
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }
        }
    }

    HourlyChart {
        Layout.fillWidth: true
    }

    ForecastList {
        Layout.fillWidth: true
    }
}
