import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Desktop

// One full-screen greeter per output. It is the lock screen's twin
// (Modules/Lock/LockContent.qml): the same blurred wallpaper (lock.jpg of the
// mode in use) under the same scrim, the same centred clock lockup, the same
// glass password pill, so boot -> login -> desktop and lock -> unlock read as
// one gesture. The differences are the avatar/name above the field and the
// session chip at the bottom (the lock's status line).
//
// Transitions fade content, never glass: the backdrop starts as the plymouth
// surface colour (no flash after the splash), the image fades in, then the
// content rises in. On a successful login the content fades and the blurred
// image dissolves into the sharp wallpaper (what the desktop shows) before
// greetd launches the session (Login.leaveMs). No niri layer rules exist in
// the greeter's niri, so the pill is a flat Glass fill, as on the lock.
PanelWindow {
    id: root

    required property ShellScreen modelData

    // Content waits for the wallpaper (or its failure) so nothing pops in.
    readonly property bool ready: lock.status === Image.Ready || lock.status === Image.Error
    // 1 = hidden (entering / leaving), 0 = fully shown.
    readonly property real veilTarget: (Login.leaving || !ready) ? 1 : 0
    property real veil: veilTarget

    Behavior on veil {
        NumberAnimation {
            duration: Theme.animSlow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Login.leaving ? Theme.curveAccelerate : Theme.curveDecelerate
        }
    }

    screen: modelData
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusionMode: ExclusionMode.Ignore
    color: Theme.surface
    WlrLayershell.namespace: "qs-greeter"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Component.onCompleted: {
        Login.leaveMs = Theme.animSlow;
        input.forceActiveFocus();
    }

    // Blurred wallpaper: same file the lock screen shows.
    Image {
        id: lock

        anchors.fill: parent
        source: "file://" + Login.stateDir + "/lock.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: root.ready ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animSlow
            }
        }
    }

    // The desktop's wallpaper, sharp: only while leaving (dissolve to session).
    Image {
        anchors.fill: parent
        source: "file://" + Login.stateDir + "/wallpaper.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: Login.leaving ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animSlow
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.imageScrim
        opacity: root.ready && !Login.leaving ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animSlow
            }
        }
    }

    Item {
        anchors.fill: parent
        // Never exactly 0: invisible items drop keyboard focus.
        opacity: Math.max(0.001, 1 - root.veil)

        transform: Translate {
            y: root.veil * Theme.enterRise
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.gapSection

            ClockLockup {
                Layout.alignment: Qt.AlignHCenter
                ink: Theme.onImage
                inkMuted: Theme.onImageMuted
                alignment: Qt.AlignHCenter
            }

            Item {
                Layout.preferredHeight: Theme.spaceMd
                Layout.preferredWidth: 1
            }

            // Avatar: ~/.face if the setup script staged one, else initial.
            Clickable {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: Theme.tileHeight
                implicitHeight: Theme.tileHeight
                radius: Theme.radiusFull
                color: Theme.tile
                onClicked: Login.cycle("userIndex", Login.users.length, 1)

                Image {
                    id: face

                    anchors.fill: parent
                    source: "file://" + Login.stateDir + "/avatar.png"
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: false
                }
                // Rounded mask for the photo (a layer so MultiEffect can read it).
                Rectangle {
                    id: mask

                    anchors.fill: parent
                    radius: Theme.radiusFull
                    layer.enabled: true
                    visible: false
                }
                MultiEffect {
                    anchors.fill: parent
                    source: face
                    maskEnabled: true
                    maskSource: mask
                    visible: face.status === Image.Ready
                }
                Label {
                    anchors.centerIn: parent
                    visible: face.status !== Image.Ready
                    text: (Login.user.name || "?").charAt(0).toUpperCase()
                    font.pixelSize: Theme.textXl
                    font.weight: Theme.weightTitle
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -Theme.gapSection + Theme.spaceSm
                text: Login.user.full
                font.pixelSize: Theme.textLg
                font.weight: Theme.weightTitle
                color: Theme.onImage
            }

            // Password pill: same size, glass and focus ring as the lock's.
            Glass {
                id: pill

                readonly property bool errored: Login.failed && !Login.busy

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Theme.popoverWidth
                Layout.preferredHeight: Theme.fieldHeight
                radius: Theme.radiusFull
                border.color: errored ? Theme.error : input.activeFocus ? Theme.primary : Theme.hairline

                Behavior on border.color {
                    ColorAnimation {
                        duration: Theme.animFast
                    }
                }

                transform: Translate {
                    id: nudge
                }

                SequentialAnimation {
                    id: shake

                    NumberAnimation { target: nudge; property: "x"; to: -Theme.spaceMd; duration: Theme.animInstant }
                    NumberAnimation { target: nudge; property: "x"; to: Theme.spaceMd; duration: Theme.animInstant }
                    NumberAnimation { target: nudge; property: "x"; to: -Theme.spaceSm; duration: Theme.animInstant }
                    NumberAnimation { target: nudge; property: "x"; to: 0; duration: Theme.animInstant }
                }

                Connections {
                    target: Login

                    function onFailedChanged() {
                        if (Login.failed) {
                            shake.restart();
                            Qt.callLater(input.forceActiveFocus);
                        }
                    }
                }

                Icon {
                    id: lockIcon

                    anchors.left: parent.left
                    anchors.leftMargin: Theme.padCard
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: Login.busy ? "hourglass_top" : "lock"
                    size: Theme.iconLg
                    color: pill.errored ? Theme.error : Theme.textMuted
                }

                Input {
                    id: input

                    anchors.left: lockIcon.right
                    anchors.leftMargin: Theme.gapInline
                    anchors.right: go.left
                    anchors.rightMargin: Theme.gapInline
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.textLg
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    enabled: !Login.busy

                    Keys.onReturnPressed: submit()
                    Keys.onEnterPressed: submit()
                    Keys.onTabPressed: Login.cycle("sessionIndex", Login.sessions.length, 1)
                    onTextChanged: if (text !== "" && Login.failed && !Login.busy) {
                        Login.failed = false;
                        Login.message = "";
                    }

                    function submit() {
                        Login.submit(text);
                        text = "";
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: input.text === ""
                        text: "Password"
                        color: Theme.textMuted
                        font.pixelSize: Theme.textLg
                    }
                }

                Clickable {
                    id: go

                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spaceSm
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.controlLg
                    height: Theme.controlLg
                    radius: Theme.radiusFull
                    onClicked: input.submit()

                    Icon {
                        anchors.centerIn: parent
                        glyph: "arrow_forward"
                        size: Theme.iconLg
                    }
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                // Reserve the line so the pill does not jump when an error shows.
                text: pill.errored && Login.message !== "" ? Login.message : " "
                color: Theme.error
                font.pixelSize: Theme.textXs
            }
        }

        // Session chip: click (or Tab) to cycle. Sits where the lock screen
        // keeps its status line, quiet at the bottom.
        Clickable {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.space2xl
            implicitHeight: Theme.control
            implicitWidth: sessionRow.implicitWidth + 2 * Theme.padControl
            radius: Theme.radiusFull
            onClicked: Login.cycle("sessionIndex", Login.sessions.length, 1)

            Row {
                id: sessionRow

                anchors.centerIn: parent
                spacing: Theme.gapInline

                Icon {
                    glyph: "desktop_windows"
                    color: Theme.onImageMuted
                }
                Label {
                    height: Theme.icon
                    text: Login.session.name
                    color: Theme.onImageMuted
                }
            }
        }
    }
}
