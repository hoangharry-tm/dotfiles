import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.Common
import qs.Services
import qs.Widgets

// Battery level meter, draw and health, charge limit and the power-profile
// switch. The parent row already says the percentage and time left.
Section {
    readonly property bool low: Power.percent < 0.15 && !Power.charging

    // Limit info is read from sysfs once per open, not polled.
    Component.onCompleted: Battery.refresh()

    Surface {
        visible: Power.hasBattery
        Layout.fillWidth: true
        implicitHeight: Theme.trackHeight
        radius: Theme.radiusFull
        variant: "trackInset" // lifts off the recessed well it sits in (dark)

        Surface {
            width: Math.max(height, parent.width * Power.percent)
            height: parent.height
            radius: Theme.radiusFull
            variant: "solid"
            // Neutral meter; only a warning swaps in a hue.
            fillA: low ? Theme.error : Theme.fillSolid

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
        font.features: { "tnum": 1 }
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
                font.features: { "tnum": 1 }
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }

            Label {
                text: Math.round(modelData.percent * 100) + "%"
                font.features: {
                    "tnum": 1
                }
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
            font.features: { "tnum": 1 }
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }

        Button {
            id: once

            visible: Battery.limitWritable && (Battery.fullOnce || Battery.limited)
            text: Battery.fullOnce ? "Restore limit" : "Charge to full once"
            Layout.rightMargin: -once.inset // hang: the label stays on the content edge
            onClicked: Battery.setFullOnce(!Battery.fullOnce)
        }
    }

    Segmented {
        Layout.fillWidth: true
        variant: "rest" // lifts off the recessed well it sits in
        model: [
            { glyph: "eco", label: "Saver", value: PowerProfile.PowerSaver },
            { glyph: "balance", label: "Balanced", value: PowerProfile.Balanced }
        ].concat(Power.hasPerformance ? [{ glyph: "bolt", label: "Performance", value: PowerProfile.Performance }] : [])
        current: Power.profile
        onPicked: v => Power.setProfile(v)
    }
}
