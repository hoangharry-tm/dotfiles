import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

// Notification history, grouped by app, with Clear.
ColumnLayout {
    spacing: Theme.gapSection // between app groups

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Theme.spaceMd

        Label {
            Layout.fillWidth: true
            text: "Notifications"
            color: Theme.textMuted
            font.pixelSize: Theme.textSm
            font.weight: Font.DemiBold
        }

        Clickable {
            visible: Notifications.history.length > 0
            implicitWidth: clear.implicitWidth + Theme.padControl * 2
            implicitHeight: Theme.controlSm
            radius: Theme.radiusFull
            onClicked: Notifications.clearAll()

            Label {
                id: clear

                anchors.centerIn: parent
                text: "Clear"
                color: Theme.textMuted
                font.pixelSize: Theme.textSm
            }
        }
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: Theme.spaceSm
        Layout.bottomMargin: Theme.spaceSm
        visible: Notifications.history.length === 0
        horizontalAlignment: Text.AlignHCenter
        text: "No notifications"
        color: Theme.textMuted
        font.pixelSize: Theme.textSm
    }

    Repeater {
        model: ScriptModel {
            values: Notifications.groupKeys
        }

        NotificationGroup {
            required property string modelData

            Layout.fillWidth: true
            groupKey: modelData
        }
    }
}
