import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

// Centred glass dialog for a polkit request. Esc cancels, Enter submits.
// Created on demand by a LazyLoader (shell.qml) while a request is pending.
PanelWindow {
    id: root

    readonly property var flow: Polkit.flow
    readonly property string message: flow?.message ?? ""
    property bool failedOnce: false
    // Same output as the other modals: wherever the user is looking.
    readonly property string focusedName: Panels.focusedScreen()

    screen: Quickshell.screens.find(s => s.name === focusedName) ?? Quickshell.screens[0]
    implicitWidth: Theme.panelWidth
    implicitHeight: sheet.implicitHeight
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.namespace: "qs-polkit"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Component.onCompleted: Qt.callLater(() => input.forceActiveFocus())

    function submit() {
        if (!flow || !flow.isResponseRequired || input.text === "")
            return;
        flow.submit(input.text);
        input.text = "";
    }

    // A failed attempt re-prompts: clear, shake, and say so.
    Connections {
        target: root.flow

        function onAuthenticationFailed() {
            root.failedOnce = true;
            input.text = "";
            shake.restart();
            input.forceActiveFocus();
        }
    }

    Glass {
        id: sheet

        width: parent.width
        implicitHeight: column.implicitHeight + Theme.padSheet * 2
        radius: Theme.radiusXl // = qs-polkit layer rule in niri/rules.kdl

        ColumnLayout {
            id: column

            // Only the content shakes: a niri-blurred sheet must stay put.
            x: Theme.padSheet
            y: Theme.padSheet
            width: parent.width - Theme.padSheet * 2
            spacing: Theme.gapSection

            SequentialAnimation {
                id: shake

                NumberAnimation { target: column; property: "x"; to: Theme.padSheet - Theme.spaceSm; duration: Theme.animInstant }
                NumberAnimation { target: column; property: "x"; to: Theme.padSheet + Theme.spaceSm; duration: Theme.animInstant }
                NumberAnimation { target: column; property: "x"; to: Theme.padSheet - Theme.spaceXs; duration: Theme.animInstant }
                NumberAnimation { target: column; property: "x"; to: Theme.padSheet; duration: Theme.animInstant }
            }

            Icon {
                Layout.alignment: Qt.AlignHCenter
                glyph: "󰌆"
                size: Theme.iconHero
                color: Theme.primary
            }

            Label {
                Layout.fillWidth: true
                text: root.message || "Authentication required"
                font.pixelSize: Theme.textLg
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                elide: Text.ElideNone
            }

            Label {
                Layout.fillWidth: true
                text: root.flow?.actionId ?? ""
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
                font.family: Theme.mono
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.controlLg
                radius: Theme.radiusMd
                color: Theme.glassSolid
                border.width: Theme.hairlineWidth
                border.color: root.failedOnce ? Theme.error : Theme.hairline

                TextInput {
                    id: input

                    anchors.fill: parent
                    anchors.leftMargin: Theme.padControl
                    anchors.rightMargin: Theme.padControl
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: Theme.textLg
                    selectionColor: Qt.alpha(Theme.primary, 0.4)
                    clip: true
                    echoMode: root.flow?.responseVisible ? TextInput.Normal : TextInput.Password
                    enabled: root.flow?.isResponseRequired ?? false

                    Keys.onEscapePressed: root.flow?.cancelAuthenticationRequest()
                    Keys.onReturnPressed: root.submit()
                    Keys.onEnterPressed: root.submit()

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: input.text === ""
                        text: (root.flow?.inputPrompt ?? "").replace(/:\s*$/, "") || "Password"
                        color: Theme.textMuted
                        font.pixelSize: Theme.textLg
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.flow?.supplementaryMessage || (root.failedOnce ? "Authentication failed. Try again." : "")
                color: (root.flow?.supplementaryIsError || root.failedOnce) ? Theme.error : Theme.textMuted
                font.pixelSize: Theme.textXs
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                elide: Text.ElideNone
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.gapInline

                Clickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.controlLg
                    radius: Theme.radiusMd
                    onClicked: root.flow?.cancelAuthenticationRequest()

                    Label {
                        anchors.centerIn: parent
                        text: "Cancel"
                    }
                }

                Clickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.controlLg
                    radius: Theme.radiusMd
                    color: pressed ? Qt.darker(Theme.primary, 1.1) : hovered ? Qt.lighter(Theme.primary, 1.08) : Theme.primary
                    onClicked: root.submit()

                    Label {
                        anchors.centerIn: parent
                        text: "Authenticate"
                        color: Theme.primaryText
                        font.weight: Font.DemiBold
                    }
                }
            }
        }
    }
}
