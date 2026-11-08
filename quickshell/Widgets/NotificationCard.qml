import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.Common
import qs.Services

// One notification: app tile, caption (app, time, close), summary, body,
// thumbnail, action pills and inline reply, on the Control Center's Surface
// material. Swipe sideways (or x) to dismiss. `notification` is a live
// Notification or a plain object restored from disk (no actions or reply).
// A NotificationGroup positions it; `shade` and `concealed` let the group
// tuck it behind the front card (a real card, so it can fan out into a list).
Item {
    id: root

    required property var notification
    property bool toast: false
    property bool showApp: true        // false inside a group whose header names the app
    property bool expandBody: false    // full body (group opened); a hovered card also shows it all
    property bool animateIn: false     // slide/fade in from the top-right on creation
    property real shade: 1             // material opacity (fades down the tucked layers)
    property bool concealed: false     // tucked behind another card: content hidden, no input
    readonly property bool hovered: hover.hovered
    readonly property bool interacting: hover.hovered || replyInput.activeFocus || drag.active
    readonly property bool critical: notification.urgency === NotificationUrgency.Critical
    // Fraction of the width a swipe must travel (or be flung past) to dismiss.
    readonly property real swipeDismiss: 0.35
    property bool leaving: false
    property real enter: animateIn ? 0 : 1

    signal closed

    implicitHeight: layout.implicitHeight + Theme.spaceMd * 2
    enabled: !concealed

    // Only cards on screen keep the once-a-minute clock running.
    onVisibleChanged: visible ? Notifications.watchers++ : Notifications.watchers--
    Component.onCompleted: {
        enter = 1; // Behavior animates it; a no-op when animateIn is false
        if (visible)
            Notifications.watchers++;
    }
    Component.onDestruction: if (visible)
        Notifications.watchers--

    // The one exit (swipe, x, middle click, an action): slide out sideways, then close.
    function dismiss(dir = 1) {
        if (leaving)
            return;
        leaving = true;
        flyOut.to = dir * (width + Theme.spaceXl);
        flyOut.start();
    }

    function sendReply() {
        const text = replyInput.text.trim();
        if (text === "")
            return;
        notification.sendInlineReply(text);
        replyInput.text = "";
        replyInput.focus = false;
        if (!notification.resident)
            dismiss();
    }

    Behavior on enter {
        NumberAnimation {
            duration: Theme.anim
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.curveDecelerate
        }
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
            if (Math.abs(card.x) > root.width * root.swipeDismiss)
                root.dismiss(card.x < 0 ? -1 : 1);
            else
                back.start();
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

    // The swipe target. The entrance is a Translate so it never fights the drag's x.
    Item {
        id: card

        width: parent.width
        height: parent.height
        opacity: (1 - Math.min(Math.abs(x) / root.width, 1) * 0.6) * root.enter
        transform: Translate {
            x: (1 - root.enter) * Theme.spaceXl
            y: (root.enter - 1) * Theme.spaceSm
        }

        // Base under the translucent tone: toasts are not blurred, so without it
        // the wallpaper shows through; it also keeps tucked layers from bleeding.
        Rectangle {
            anchors.fill: parent
            radius: root.toast ? Theme.radiusLg : Theme.radiusMd
            color: Theme.glassSolid
            opacity: root.shade
        }

        Surface {
            anchors.fill: parent
            variant: "aurora"
            radius: root.toast ? Theme.radiusLg : Theme.radiusMd
            hovered: root.hovered
            opacity: root.shade
        }

        // Click: default action + focus the app. Under the content, so buttons win.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onClicked: m => m.button === Qt.MiddleButton ? root.dismiss() : Notifications.activate(root.notification)
        }

        ColumnLayout {
            id: layout

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spaceMd
            spacing: Theme.spaceXs
            // Tucked cards show material only; their text would bleed through the front card.
            opacity: root.concealed ? 0 : 1
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animFast
                }
            }

            // Sonoma layout: app tile | caption + summary + body | thumbnail.
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spaceMd

                // Uniform tile whatever the icon's shape or resolution; an app
                // initial stands in when the icon is missing or fails to load.
                Rectangle {
                    id: tile

                    readonly property string source: root.showApp ? Notifications.appIconOf(root.notification) : ""
                    readonly property bool hasIcon: source !== "" && appIcon.status !== Image.Error

                    visible: root.showApp
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: Theme.controlLg
                    Layout.preferredHeight: Theme.controlLg
                    radius: Theme.radiusSm
                    color: Theme.tile

                    IconImage {
                        id: appIcon

                        anchors.centerIn: parent
                        implicitSize: Theme.iconApp
                        source: tile.source
                        visible: tile.hasIcon
                    }

                    Label {
                        anchors.centerIn: parent
                        visible: !tile.hasIcon
                        text: (root.notification.appName || "?").charAt(0).toUpperCase()
                        color: Theme.textMuted
                        font.pixelSize: Theme.textLg
                        font.weight: Theme.weightTitle
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: Theme.spaceXs

                    // Caption: "App  time", close on hover. The button's negative
                    // margins keep the line text-high.
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.gapInline

                        Label {
                            Layout.fillWidth: true
                            text: (root.showApp ? (root.notification.appName || "Notification") + "  ·  " : "") + Notifications.timeAgo(root.notification)
                            elide: Text.ElideRight
                            color: Theme.textMuted
                            font.pixelSize: Theme.textXs
                            font.weight: Theme.weightEmphasis
                            font.features: {
                                "tnum": 1
                            }
                        }

                        Icon {
                            visible: root.critical
                            glyph: "error"
                            filled: true
                            size: Theme.iconSm
                            color: Theme.error
                        }

                        Clickable {
                            Layout.preferredWidth: Theme.controlSm
                            Layout.preferredHeight: Theme.controlSm
                            Layout.topMargin: -Theme.spaceXs
                            Layout.bottomMargin: -Theme.spaceXs
                            radius: Theme.radiusFull
                            enabled: root.hovered
                            opacity: root.hovered ? 1 : 0
                            onClicked: root.dismiss()

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Theme.animFast
                                }
                            }

                            Icon {
                                anchors.centerIn: parent
                                glyph: "close"
                                size: Theme.iconSm
                            }
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: root.notification.summary
                        font.weight: Theme.weightEmphasis
                    }

                    Label {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: root.notification.body
                        textFormat: Text.StyledText
                        color: Theme.textMuted
                        lineHeight: Theme.lineHeight
                        wrapMode: Text.Wrap
                        maximumLineCount: root.expandBody || root.hovered ? 100 : 2
                        onLinkActivated: link => Qt.openUrlExternally(link)
                    }
                }

                // Scaled at decode time (sourceSize) so a huge image never sits
                // in memory at full resolution.
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
                                root.dismiss();
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

                Input {
                    id: replyInput

                    anchors.left: parent.left
                    anchors.right: send.left
                    anchors.leftMargin: Theme.padControl
                    anchors.verticalCenter: parent.verticalCenter
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
                        glyph: "send"
                    }
                }
            }
        }
    }
}
