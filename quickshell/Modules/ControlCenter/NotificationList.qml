import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Notification history with Clear.
ColumnLayout {
    spacing: 8

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 4

        Label {
            Layout.fillWidth: true
            text: "Notifications"
            color: Theme.textMuted
            font.pixelSize: Theme.textSm
            font.weight: Font.DemiBold
        }

        Clickable {
            visible: Notifications.history.length > 0
            implicitWidth: clear.implicitWidth + 18
            implicitHeight: 24
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
        Layout.topMargin: 8
        Layout.bottomMargin: 8
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
