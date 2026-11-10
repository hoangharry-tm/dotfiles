import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Pulsing "sharing" glyph while niri reports an active screencast. Hover lists
// what is shared; each entry has a Stop pill (niri stop-cast), plus Stop all.
BarChip {
    id: root

    wanted: Privacy.sharing
    // Never collapsed: it is a safety/recording indicator.

    Icon {
        glyph: "screen_record"
        color: Theme.error

        // Shared stepped pulse (Common/Pulse.qml): no per-frame repaints.
        opacity: root.visible ? Pulse.opacity : 1
    }

    Popover {
        target: root
        shown: root.hovered
        interactive: true       // has Stop buttons: stays open under the pointer
        padding: Theme.padControl

        Label {
            text: "Sharing your screen"
            color: Theme.textMuted
            font.pixelSize: Theme.textSm
        }

        Repeater {
            model: Privacy.casts

            RowLayout {
                required property var modelData

                Layout.fillWidth: true
                spacing: Theme.gapInline

                Label {
                    Layout.fillWidth: true
                    Layout.maximumWidth: Theme.control * 8
                    elide: Text.ElideRight
                    text: modelData.app ? modelData.target + "  ·  " + modelData.app : modelData.target
                }

                PillButton {
                    danger: true
                    text: "Stop"
                    onClicked: Niri.stopCast(modelData.id)
                }
            }
        }

        PillButton {
            danger: true
            visible: Privacy.casts.length > 1
            Layout.alignment: Qt.AlignRight
            text: "Stop all"
            onClicked: Privacy.casts.forEach(c => Niri.stopCast(c.id))
        }
    }

    onVisibleChanged: visible ? Pulse.hold() : Pulse.release()
    Component.onCompleted: if (visible)
        Pulse.hold()
    Component.onDestruction: if (visible)
        Pulse.release()
}
