import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

// One full-screen greeter per output: wallpaper, dim, centered card with
// clock, avatar + name, password pill and session selector.
// No niri layer rules apply here (the greeter has its own niri config), so
// the card is flat: glassSolid fill + hairline, as DESIGN.md says for
// unblurred surfaces.
PanelWindow {
    id: root

    required property ShellScreen modelData

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

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Image {
        anchors.fill: parent
        source: "file://" + Login.stateDir + "/lock.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Theme.surface, 0.35)
    }

    Rectangle {
        id: card

        anchors.centerIn: parent
        width: Theme.panelWidth
        height: col.implicitHeight + 2 * Theme.spaceXl
        radius: Theme.radiusXl
        color: Theme.glassSolid
        border.width: Theme.hairlineWidth
        border.color: Theme.hairline

        // Entrance: rises and fades in (nothing here is compositor-drawn).
        property real shown: 0

        opacity: shown
        transform: Translate {
            y: (1 - card.shown) * Theme.enterRise
        }
        Component.onCompleted: {
            shown = 1;
            input.forceActiveFocus();
        }
        Behavior on shown {
            NumberAnimation {
                duration: Theme.anim
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.curveDecelerate
            }
        }

        ColumnLayout {
            id: col

            anchors.fill: parent
            anchors.margins: Theme.spaceXl
            spacing: Theme.gapSection

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatTime(clock.date, "HH:mm")
                font.pixelSize: Theme.textHero * 2
                font.weight: Font.Light
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -Theme.gapSection + Theme.spaceXs
                text: Qt.formatDate(clock.date, "dddd, d MMMM")
                font.pixelSize: Theme.textLg
                color: Theme.textMuted
            }

            // Avatar: ~/.face if the setup script staged one, else initial.
            Clickable {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Theme.gapSection
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
                    font.weight: Font.DemiBold
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -Theme.gapSection + Theme.spaceSm
                text: Login.user.full
                font.pixelSize: Theme.textLg
                font.weight: Font.DemiBold
            }

            // Password pill.
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: Theme.fieldHeight
                radius: Theme.radiusFull
                color: Theme.tile
                border.width: input.activeFocus ? Theme.hairlineWidth : 0
                border.color: Theme.primary

                TextInput {
                    id: input

                    anchors.fill: parent
                    anchors.leftMargin: Theme.spaceXl
                    anchors.rightMargin: Theme.fieldHeight
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "●"
                    enabled: !Login.busy
                    color: Theme.text
                    selectionColor: Theme.primary
                    selectedTextColor: Theme.primaryText
                    font.family: Theme.font
                    font.pixelSize: Theme.textLg
                    clip: true
                    Keys.onReturnPressed: go()
                    Keys.onEnterPressed: go()
                    Keys.onTabPressed: Login.cycle("sessionIndex", Login.sessions.length, 1)

                    function go() {
                        Login.submit(text);
                        text = "";
                    }

                    Label {
                        anchors.fill: parent
                        visible: !input.text
                        text: Login.busy ? "Signing in…" : "Password"
                        color: Theme.textMuted
                        font.pixelSize: Theme.textLg
                    }
                }

                Clickable {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: Theme.spaceSm
                    width: Theme.controlLg
                    height: Theme.controlLg
                    radius: Theme.radiusFull
                    onClicked: input.go()

                    Icon {
                        anchors.centerIn: parent
                        glyph: "󰁔"
                        size: Theme.iconLg
                    }
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -Theme.gapSection + Theme.spaceSm
                visible: Login.message !== ""
                text: Login.message
                color: Theme.error
            }

            // Session selector: click (or Tab) to cycle.
            Clickable {
                Layout.alignment: Qt.AlignHCenter
                implicitHeight: Theme.control
                implicitWidth: sessionRow.implicitWidth + 2 * Theme.padControl
                radius: Theme.radiusFull
                onClicked: Login.cycle("sessionIndex", Login.sessions.length, 1)

                Row {
                    id: sessionRow

                    anchors.centerIn: parent
                    spacing: Theme.gapInline

                    Icon {
                        glyph: "󰍹"
                        color: Theme.textMuted
                    }
                    Label {
                        height: Theme.icon
                        text: Login.session.name
                        color: Theme.textMuted
                    }
                }
            }
        }
    }
}
