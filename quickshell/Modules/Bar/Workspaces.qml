import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

// Page-dot workspaces: the active one stretches into a pill.
Row {
    id: root

    required property string output

    spacing: 2
    leftPadding: 4
    rightPadding: 4

    Repeater {
        model: Niri.workspacesOn(root.output)

        Clickable {
            id: ws

            required property var modelData

            readonly property bool active: modelData.is_active
            readonly property bool occupied: modelData.active_window_id !== null || Niri.windowsOn(modelData.id).length > 0

            width: 22
            height: 24
            radius: Theme.radiusSm
            onClicked: Niri.focusWorkspace(modelData.id)

            Rectangle {
                anchors.centerIn: parent
                width: ws.active ? 16 : 6
                height: 6
                radius: 3
                color: ws.active ? Theme.primary : ws.occupied ? Theme.text : Theme.outline
                opacity: ws.active || ws.occupied ? 1 : 0.6

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.anim
                        easing.type: Theme.easing
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.anim
                    }
                }
            }
        }
    }
}
