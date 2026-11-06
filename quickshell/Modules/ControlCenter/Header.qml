import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets

// Who and how long (uptime), plus session shortcuts (wallpaper, lock, power).
RowLayout {
    id: root

    // True while the sheet is open: uptime is read then, never in the background.
    property bool active: false
    property string uptime: ""

    spacing: Theme.gapInline

    onActiveChanged: if (active)
        uptimeFile.reload()

    FileView {
        id: uptimeFile

        path: "/proc/uptime"
        onLoaded: {
            const s = parseFloat(text());
            const d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60);
            root.uptime = "Up " + (d ? d + " d " : "") + (h ? h + " h " : "") + m + " min";
        }
    }

    Column {
        Layout.fillWidth: true
        Layout.leftMargin: Theme.spaceXs

        Label {
            width: parent.width
            text: Quickshell.env("USER")
            font.pixelSize: Theme.textLg
            font.weight: Font.DemiBold
        }

        Label {
            width: parent.width
            text: root.uptime
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }
    }

    Repeater {
        model: [
            { glyph: "󰸉", tip: "Wallpaper", run: () => Quickshell.execDetached(["wallpaper", "pick"]) },
            { glyph: "󰒓", tip: "Settings", run: () => Panels.toggle("settings") },
            { glyph: "󰌾", tip: "Lock", run: () => Quickshell.execDetached(["lock-screen"]) },
            { glyph: "󰐥", tip: "Power", run: () => Panels.toggle("power") }
        ]

        Clickable {
            id: action

            required property var modelData

            Layout.preferredWidth: Theme.control
            Layout.preferredHeight: Theme.control
            radius: Theme.radiusFull
            color: "transparent"
            onClicked: {
                Panels.close();
                modelData.run();
            }

            Surface {
                anchors.fill: parent
                radius: parent.radius
                hovered: action.hovered
                pressed: action.pressed
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
