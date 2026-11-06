import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.Common
import qs.Services
import qs.Widgets

// Battery (percentage, time, draw, health) and the power-profile switch.
Section {
    readonly property bool low: Power.percent < 0.15 && !Power.charging

    RowLayout {
        visible: Power.hasBattery
        Layout.fillWidth: true
        spacing: Theme.gapInline

        Icon {
            glyph: Power.icon
            size: Theme.iconLg
            color: low ? Theme.error : Theme.text
        }

        Label {
            text: Math.round(Power.percent * 100) + "%"
            font.pixelSize: Theme.textXl
            font.weight: Font.DemiBold
        }

        Item {
            Layout.fillWidth: true
        }

        Label {
            text: Power.timeLabel
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }
    }

    Rectangle {
        visible: Power.hasBattery
        Layout.fillWidth: true
        implicitHeight: Theme.trackHeight
        radius: Theme.radiusFull
        color: Theme.tile

        Rectangle {
            width: Math.max(height, parent.width * Power.percent)
            height: parent.height
            radius: Theme.radiusFull
            color: low ? Theme.error : Power.charging ? Theme.tertiary : Theme.primary

            Behavior on width {
                NumberAnimation {
                    duration: Theme.anim
                    easing.type: Theme.easing
                }
            }
        }
    }

    Label {
        visible: Power.hasBattery
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.spaceXs
        text: [Power.charging ? "Charging" : Power.plugged ? "On AC" : "On battery", Power.watts > 0 ? Power.watts.toFixed(1) + " W" : "", Power.health >= 0 ? "Health " + Math.round(Power.health) + "%" : ""].filter(t => t).join("  ·  ")
        color: Theme.textMuted
        font.pixelSize: Theme.textXs
    }

    Segmented {
        Layout.fillWidth: true
        model: [
            { glyph: "󰌪", label: "Saver", value: PowerProfile.PowerSaver },
            { glyph: "󰾅", label: "Balanced", value: PowerProfile.Balanced }
        ].concat(Power.hasPerformance ? [{ glyph: "󰓅", label: "Performance", value: PowerProfile.Performance }] : [])
        current: Power.profile
        onPicked: v => Power.setProfile(v)
    }
}
