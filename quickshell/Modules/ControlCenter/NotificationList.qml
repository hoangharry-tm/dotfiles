import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Notification history with Clear.
ColumnLayout {
    spacing: Theme.gapStack

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
        model: Notifications.history

        NotificationCard {
            required property var modelData

            Layout.fillWidth: true
            notification: modelData
            onClosed: Notifications.dismiss(modelData)
        }
    }
}
