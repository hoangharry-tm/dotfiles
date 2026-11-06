import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

// Battery at a glance + quick actions (wallpaper, screenshot, lock, power).
RowLayout {
    spacing: Theme.gapInline

    Icon {
        visible: Power.hasBattery
        glyph: Power.icon
        size: Theme.iconLg
        color: Power.percent < 0.15 && !Power.charging ? Theme.error : Theme.text
    }

    Column {
        Layout.fillWidth: true
        Layout.leftMargin: Theme.spaceXs

        Label {
            text: Power.hasBattery ? Math.round(Power.percent * 100) + "%" : "Plugged in"
            font.pixelSize: Theme.textLg
            font.weight: Font.DemiBold
        }

        Label {
            text: Power.timeLabel
            visible: text !== ""
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }
    }

    Repeater {
        model: [
            { glyph: "󰸉", tip: "Wallpaper", run: () => Quickshell.execDetached(["wallpaper", "pick"]) },
            { glyph: "󰹑", tip: "Screenshot", run: () => Quickshell.execDetached(["sh", "-c", "sleep 0.3; niri msg action screenshot"]) },
            { glyph: "󰌾", tip: "Lock", run: () => Quickshell.execDetached(["lock-screen"]) },
            { glyph: "󰐥", tip: "Power", run: () => Panels.toggle("power") }
        ]

        Clickable {
            id: action

            required property var modelData

            Layout.preferredWidth: Theme.control
            Layout.preferredHeight: Theme.control
            radius: Theme.radiusFull
            color: hovered ? Theme.pressed : Theme.tile
            onClicked: {
                Panels.close();
                modelData.run();
            }

            Icon {
                anchors.centerIn: parent
                glyph: action.modelData.glyph
            }

            Tooltip {
                target: action
                shown: action.hovered

                Label {
                    text: action.modelData.tip
                    font.pixelSize: Theme.textSm
                }
            }
        }
    }
}
