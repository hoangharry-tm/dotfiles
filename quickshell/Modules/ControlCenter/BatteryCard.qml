import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.Common
import qs.Services
import qs.Widgets

// Battery (percentage, time, draw, health) and the power-profile switch.
Section {
    readonly property bool low: Power.percent < 0.15 && !Power.charging

    // Limit info is read from sysfs once per open, not polled.
    Component.onCompleted: Battery.refresh()

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

    Surface {
        visible: Power.hasBattery
        Layout.fillWidth: true
        implicitHeight: Theme.trackHeight
        radius: Theme.radiusFull
        variant: "recessed"

        Surface {
            width: Math.max(height, parent.width * Power.percent)
            height: parent.height
            radius: Theme.radiusFull
            variant: "accent"
            // Accent gradient normally; only a warning swaps in a hue.
            fillA: low ? Theme.error : Power.charging ? Theme.tertiary : Theme.toneAccentA
            fillB: low ? Theme.error : Power.charging ? Theme.tertiary : Theme.toneAccentB

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

    // One row per battery when there are several (T480: internal + external).
    Repeater {
        model: Battery.multi ? Battery.batteries : []

        RowLayout {
            required property var modelData

            Layout.fillWidth: true
            spacing: Theme.gapInline

            Label {
                text: modelData.name
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }

            Label {
                Layout.fillWidth: true
                text: modelData.charging ? "Charging" : modelData.discharging ? "Discharging" : modelData.full ? "Full" : "Idle"
                font.pixelSize: Theme.textXs
                color: modelData.discharging ? Theme.text : Theme.textMuted
            }

            Label {
                text: modelData.health >= 0 ? "Health " + Math.round(modelData.health) + "%" : ""
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }

            Label {
                text: Math.round(modelData.percent * 100) + "%"
                font.family: Theme.mono
                font.pixelSize: Theme.textXs
            }
        }
    }

    RowLayout {
        visible: Battery.limitSupported
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.spaceXs
        spacing: Theme.gapInline

        Label {
            Layout.fillWidth: true
            text: Battery.fullOnce ? "Charging to 100% once" : "Charge limit " + Battery.activeStop + "%"
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }

        Clickable {
            visible: Battery.limitWritable && (Battery.fullOnce || Battery.limited)
            implicitWidth: onceLabel.implicitWidth + Theme.padControl * 2
            implicitHeight: Theme.controlSm
            onClicked: Battery.setFullOnce(!Battery.fullOnce)

            Label {
                id: onceLabel

                anchors.centerIn: parent
                text: Battery.fullOnce ? "Restore limit" : "Charge to full once"
                font.pixelSize: Theme.textXs
            }
        }
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
