import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Shown only while a removable drive is mounted (Services/Drives, event
// driven). Hover lists the drives with an Eject pill; click ejects the only one.
// Collapse: goes at level 3 with the input-method chip.
BarChip {
    id: root

    readonly property int hideLevel: 3

    wanted: Drives.any
    widthAt: l => l < hideLevel ? chipWidth(Theme.icon) : 0

    onClicked: if (Drives.drives.length === 1)
        Drives.eject(Drives.drives[0])

    Icon {
        glyph: "usb"
    }

    Popover {
        target: root
        shown: root.hovered
        interactive: true
        padding: Theme.padControl

        Label {
            text: "Removable drives"
            color: Theme.textMuted
            font.pixelSize: Theme.textSm
        }

        Repeater {
            model: Drives.drives

            RowLayout {
                required property var modelData

                Layout.fillWidth: true
                spacing: Theme.gapInline

                Label {
                    Layout.fillWidth: true
                    Layout.maximumWidth: Theme.control * 8
                    elide: Text.ElideRight
                    text: modelData.label + "  ·  " + modelData.size
                }

                Clickable {
                    implicitWidth: ejectLabel.implicitWidth + Theme.padControl * 2
                    implicitHeight: Theme.control - Theme.spaceSm
                    radius: Theme.radiusFull
                    color: pressed ? Theme.pressed : hovered ? Theme.hover : Theme.surfaceHigh
                    onClicked: Drives.eject(modelData)

                    Label {
                        id: ejectLabel

                        anchors.centerIn: parent
                        text: "Eject"
                        font.pixelSize: Theme.textSm
                    }
                }
            }
        }
    }
}
