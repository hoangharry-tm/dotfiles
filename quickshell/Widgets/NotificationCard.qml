import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.Common
import qs.Services

// One notification: app icon, (app ·) time, summary, body, image, actions and
// inline reply. Swipe sideways to dismiss. `notification` is a live
// Notification or a plain object restored from disk (no actions or reply).
// Used by toasts and by the Control Center groups.
Item {
    id: root

    required property var notification
    property bool toast: false
    property bool showApp: true        // false inside a group whose header names the app
    readonly property bool hovered: hover.hovered
    readonly property bool interacting: hover.hovered || replyInput.activeFocus || drag.active
    readonly property bool critical: notification.urgency === NotificationUrgency.Critical
    // Fraction of the width a swipe must travel (or be flung past) to dismiss.
    readonly property real swipeDismiss: 0.35

    signal closed

    implicitHeight: card.implicitHeight
    clip: false

    // Only cards on screen keep the once-a-minute clock running.
    onVisibleChanged: visible ? Notifications.watchers++ : Notifications.watchers--
    Component.onCompleted: if (visible)
        Notifications.watchers++
    Component.onDestruction: if (visible)
        Notifications.watchers--

    function sendReply() {
        const text = replyInput.text.trim();
        if (text === "")
            return;
        notification.sendInlineReply(text);
        replyInput.text = "";
        replyInput.focus = false;
        if (!notification.resident)
            closed();
    }

    HoverHandler {
        id: hover
    }

    // Swipe: follow the finger, then fly out past the threshold or spring back.
    DragHandler {
        id: drag

        target: card
        yAxis.enabled: false
        cursorShape: Qt.ArrowCursor
        onActiveChanged: {
            if (active)
                return;
            if (Math.abs(card.x) > root.width * root.swipeDismiss) {
                flyOut.to = card.x < 0 ? -root.width : root.width;
                flyOut.start();
            } else {
                back.start();
            }
        }
    }

    NumberAnimation {
        id: back

        target: card
        property: "x"
        to: 0
        duration: Theme.anim
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.curveDecelerate
    }

    NumberAnimation {
        id: flyOut

        target: card
        property: "x"
        duration: Theme.animExit
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.curveAccelerate
        onFinished: root.closed()
    }

    Rectangle {
        id: card

        width: parent.width
        implicitHeight: layout.implicitHeight + Theme.spaceMd * 2
        radius: root.toast ? Theme.radiusLg : Theme.radiusMd
        color: root.toast ? Theme.glassSolid : Theme.tile
        // Critical: an accent rim; toasts have no blur so keep a hairline.
        border.width: root.critical ? Theme.trackThin : root.toast ? Theme.hairlineWidth : 0
        border.color: root.critical ? Theme.tertiary : Theme.hairline
        opacity: 1 - Math.min(Math.abs(x) / root.width, 1) * 0.6

        // Click: default action + focus the app. Under the content, so buttons win.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onClicked: m => m.button === Qt.MiddleButton ? root.closed() : Notifications.activate(root.notification)
        }

        RowLayout {
            id: layout

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spaceMd
            spacing: Theme.spaceMd

            Item {
                visible: root.showApp
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: Theme.iconApp
                Layout.preferredHeight: Theme.iconApp

                readonly property string source: Notifications.appIconOf(root.notification)

                IconImage {
                    anchors.fill: parent
                    source: parent.source
                    visible: parent.source !== ""
                }

                Icon {
                    anchors.centerIn: parent
                    glyph: "󰂚"
                    size: Theme.iconLg
                    visible: parent.source === ""
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceXs

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        text: root.showApp ? (root.notification.appName || "Notification") : Notifications.timeAgo(root.notification)
                        color: Theme.textMuted
                        font.pixelSize: Theme.textXs
                    }

                    Label {
                        visible: root.showApp
                        text: Notifications.timeAgo(root.notification)
                        color: Theme.textMuted
                        font.pixelSize: Theme.textXs
                    }

                    Clickable {
                        Layout.preferredWidth: Theme.controlSm
                        Layout.preferredHeight: Theme.controlSm
                        radius: Theme.radiusFull
                        opacity: root.hovered ? 1 : 0
                        onClicked: root.closed()

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.animFast
                            }
                        }

                        Icon {
                            anchors.centerIn: parent
                            glyph: "󰅖"
                            size: Theme.iconSm
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
                    lineHeight: Theme.lineHeight
                    wrapMode: Text.Wrap
                    maximumLineCount: root.toast ? 3 : 5
                    onLinkActivated: link => Qt.openUrlExternally(link)
                }

                Flow {
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.spaceSm
                    spacing: Theme.spaceSm
                    visible: actions.count > 0

                    Repeater {
                        id: actions

                        model: (root.notification.actions ?? []).filter(a => a.identifier !== "default" && a.text)

                        Clickable {
                            required property var modelData

                            width: actionLabel.implicitWidth + Theme.padControl * 2
                            height: Theme.control
                            radius: Theme.radiusFull
                            color: hovered ? Theme.pressed : Theme.tile
                            onClicked: {
                                modelData.invoke();
                                if (!root.notification.resident)
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

                // Inline reply (the sender advertises it per notification).
                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.spaceSm
                    visible: root.notification.hasInlineReply === true
                    implicitHeight: Theme.control
                    radius: Theme.radiusFull
                    color: Theme.tile

                    TextInput {
                        id: replyInput

                        anchors.left: parent.left
                        anchors.right: send.left
                        anchors.leftMargin: Theme.padControl
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: Theme.textMd
                        clip: true
                        selectByMouse: true
                        onAccepted: root.sendReply()
                        Keys.onEscapePressed: focus = false

                        Label {
                            visible: !parent.text && !parent.activeFocus
                            text: root.notification.inlineReplyPlaceholder || "Reply"
                            color: Theme.textMuted
                        }
                    }

                    Clickable {
                        id: send

                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: Theme.control
                        radius: Theme.radiusFull
                        opacity: replyInput.text.trim() === "" ? 0.5 : 1
                        onClicked: root.sendReply()

                        Icon {
                            anchors.centerIn: parent
                            glyph: "󰒊"
                        }
                    }
                }
            }

            // Image content, scaled at decode time (sourceSize) so a huge
            // image never sits in memory at full resolution.
            ClippingRectangle {
                visible: !!root.notification.image
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: Theme.controlLg + Theme.spaceXl
                Layout.preferredHeight: Theme.controlLg + Theme.spaceXl
                radius: Theme.radiusSm
                color: Theme.tile

                Image {
                    anchors.fill: parent
                    source: root.notification.image ?? ""
                    sourceSize.width: width * Screen.devicePixelRatio
                    sourceSize.height: height * Screen.devicePixelRatio
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }
        }
    }
}
