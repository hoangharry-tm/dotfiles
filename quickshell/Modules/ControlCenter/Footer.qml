import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Widgets

// Quiet session row: wallpaper, settings, lock, power. Bare icons that get a
// fill only on hover/press, spread evenly so nothing competes with the content.
RowLayout {
    id: root

    spacing: 0

    Repeater {
        model: [
            { glyph: "wallpaper", tip: "Wallpaper", run: () => Quickshell.execDetached(["wallpaper", "pick"]) },
            { glyph: "settings", tip: "Settings", run: () => Panels.toggle("settings") },
            { glyph: "lock", tip: "Lock", run: () => Quickshell.execDetached(["lock-screen"]) },
            { glyph: "power_settings_new", tip: "Power", run: () => Panels.toggle("power") }
        ]

        Item {
            id: slot

            required property var modelData

            Layout.fillWidth: true
            Layout.preferredWidth: 1
            implicitHeight: Theme.control

            Button {
                anchors.centerIn: parent
                glyph: slot.modelData.glyph
                tip: slot.modelData.tip
                onClicked: {
                    Panels.close();
                    slot.modelData.run();
                }
            }
        }
    }
}
