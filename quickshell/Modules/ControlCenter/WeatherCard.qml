import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Where, how it feels, a 12 h trend and the 5-day outlook. The parent row
// already says the temperature and sky, so this does not repeat them.
Section {
    id: root

    // Static headline: place on column A's badge box, text on column B.
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spaceMd

        Item {
            Layout.preferredWidth: Theme.control
            Layout.preferredHeight: Theme.control

            Icon {
                anchors.centerIn: parent
                glyph: "location_on"
                color: Theme.textMuted
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Label {
                Layout.fillWidth: true
                text: Weather.city
            }

            Label {
                Layout.fillWidth: true
                text: "Feels like " + Math.round(Weather.feels) + "°  ·  " + Math.round(Weather.humidity) + "% humidity"
                font.features: { "tnum": 1 }
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }
        }

        Button {
            id: refresh

            glyph: "refresh"
            tip: "Refresh"
            Layout.rightMargin: -refresh.inset // hang: the icon stays on the content edge
            onClicked: Weather.refresh()
        }
    }

    HourlyChart {
        Layout.fillWidth: true
    }

    ForecastList {
        Layout.fillWidth: true
    }
}
