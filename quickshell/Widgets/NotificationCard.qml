import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.Common
import qs.Services

// One notification: icon, app · time, summary, body, actions, close.
// Used by toasts and by the Control Center history.
Rectangle {
    id: root

    required property Notification notification
    property bool toast: false
    readonly property alias hovered: hover.containsMouse

    signal closed

    implicitHeight: layout.implicitHeight + 24
    radius: Theme.radiusMd
    color: toast ? Theme.glassSolid : Theme.tile
    border.width: 1
    border.color: notification.urgency === NotificationUrgency.Critical ? Theme.error : Theme.hairline

    readonly property string iconSource: {
        const n = notification;
        if (n.image)
            return n.image;
        if (n.appIcon)
            return n.appIcon.startsWith("/") || n.appIcon.startsWith("file:") ? n.appIcon : Quickshell.iconPath(n.appIcon, true);
        const entry = n.desktopEntry ? DesktopEntries.byId(n.desktopEntry) : null;
        return entry ? Quickshell.iconPath(entry.icon, true) : "";
    }

    MouseArea {
        id: hover

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: m => {
            if (m.button === Qt.MiddleButton) {
                root.closed();
                return;
            }
            const def = root.notification.actions.find(a => a.identifier === "default");
            if (def) {
                def.invoke();
                root.closed();
            }
        }
    }

    RowLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 12

        ClippingRectangle {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: Theme.radiusSm
            color: Theme.tile

            IconImage {
                anchors.fill: parent
                anchors.margins: root.notification.image ? 0 : 4
                source: root.iconSource
                visible: root.iconSource !== ""
            }

            Icon {
                anchors.centerIn: parent
                glyph: "󰂚"
                visible: root.iconSource === ""
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true

                Label {
                    Layout.fillWidth: true
                    text: root.notification.appName || "Notification"
                    color: Theme.textMuted
                    font.pixelSize: Theme.textXs
                }

                Label {
                    text: Notifications.timeAgo(root.notification)
                    color: Theme.textMuted
                    font.pixelSize: Theme.textXs
                }

                Clickable {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    radius: 10
                    opacity: hover.containsMouse || hovered ? 1 : 0
                    onClicked: root.closed()

                    Icon {
                        anchors.centerIn: parent
                        glyph: "󰅖"
                        size: 12
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: root.notification.summary
                font.weight: Font.DemiBold
                maximumLineCount: 2
                wrapMode: Text.Wrap
            }

            Label {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.notification.body
                textFormat: Text.StyledText
                color: Theme.textMuted
                font.pixelSize: Theme.textSm
                wrapMode: Text.Wrap
                maximumLineCount: root.toast ? 3 : 5
                onLinkActivated: link => Qt.openUrlExternally(link)
            }

            Flow {
                Layout.fillWidth: true
                Layout.topMargin: 6
                spacing: 6
                visible: actions.count > 0

                Repeater {
                    id: actions

                    model: root.notification.actions.filter(a => a.identifier !== "default")

                    Clickable {
                        required property NotificationAction modelData

                        width: actionLabel.implicitWidth + 20
                        height: 26
                        color: hovered ? Theme.pressed : Theme.tile
                        onClicked: {
                            modelData.invoke();
                            root.closed();
                        }

                        Label {
                            id: actionLabel

                            anchors.centerIn: parent
                            text: parent.modelData.text
                            font.pixelSize: Theme.textSm
                        }
                    }
                }
            }
        }
    }
}
