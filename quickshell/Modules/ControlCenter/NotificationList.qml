import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

// Notification history, grouped by app, with Clear. The parent row is titled
// "Notifications", so the well has no heading of its own.
Section {
    spacing: Theme.gapSection // between app groups

    RowLayout {
        Layout.fillWidth: true
        visible: Notifications.history.length > 0

        Item {
            Layout.fillWidth: true
        }

        Button {
            id: clear

            text: "Clear"
            Layout.rightMargin: -clear.inset // hang: the label stays on the content edge
            onClicked: Notifications.clearAll()
        }
    }

    Label {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.rowHeight
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
