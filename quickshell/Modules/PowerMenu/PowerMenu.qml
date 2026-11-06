import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Widgets

// Full-screen frosted overlay with Lock · Sleep · Log out · Restart · Shut down.
// ←/→ to choose, Enter to confirm, Esc or click the backdrop to cancel.
PanelWindow {
    id: root

    required property ShellScreen modelData
    readonly property bool shown: Panels.isOpen("power", modelData.name)
    property int selected: 0

    readonly property var actions: [
        { glyph: "󰌾", label: "Lock", command: ["lock-screen"] },
        { glyph: "󰤄", label: "Sleep", command: ["systemctl", "suspend"] },
        { glyph: "󰍃", label: "Log out", command: ["niri", "msg", "action", "quit", "--skip-confirmation"] },
        { glyph: "󰜉", label: "Restart", command: ["systemctl", "reboot"] },
        { glyph: "󰐥", label: "Shut down", command: ["systemctl", "poweroff"] }
    ]

    function run(i) {
        Panels.close();
        Quickshell.execDetached(actions[i].command);
    }

    screen: modelData
    visible: shown
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusionMode: ExclusionMode.Ignore
    color: Theme.scrim
    WlrLayershell.namespace: "qs-power"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Created on demand by a LazyLoader (shell.qml), so also run on creation.
    Component.onCompleted: if (shown) Qt.callLater(opened)
    onShownChanged: opened()

    function opened() {
        if (!shown)
            return;
        selected = 0;
        keys.forceActiveFocus();
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Panels.close()
    }

    Item {
        id: keys

        focus: true
        Keys.onEscapePressed: Panels.close()
        Keys.onLeftPressed: root.selected = (root.selected + root.actions.length - 1) % root.actions.length
        Keys.onRightPressed: root.selected = (root.selected + 1) % root.actions.length
        Keys.onReturnPressed: root.run(root.selected)
        Keys.onEnterPressed: root.run(root.selected)
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.space2xl

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "Goodbye for now"
            font.pixelSize: Theme.textHero
            font.weight: Font.Light
        }

        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.spaceXl

            Repeater {
                model: root.actions

                Column {
                    id: action

                    required property var modelData
                    required property int index
                    readonly property bool current: root.selected === index

                    spacing: Theme.spaceMd

                    Enter {
                        active: root.shown
                        index: action.index
                    }

                    Rectangle {
                        width: Theme.space2xl * 3
                        height: width
                        radius: width / 2
                        color: action.current ? Theme.primary : mouse.containsMouse ? Theme.glassSolid : Theme.glass
                        border.width: Theme.hairlineWidth
                        border.color: Theme.hairline
                        scale: mouse.pressed ? Theme.pressScale : action.current ? 1 + (1 - Theme.pressScale) : 1

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animFast
                            }
                        }

                        Behavior on scale {
                            SpringAnimation {
                                spring: Theme.springStiff
                                damping: Theme.springDamp
                                epsilon: 0.001
                            }
                        }

                        Icon {
                            anchors.centerIn: parent
                            glyph: action.modelData.glyph
                            size: Theme.iconHero
                            color: action.current ? Theme.primaryText : Theme.text
                        }

                        MouseArea {
                            id: mouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.selected = action.index
                            onClicked: root.run(action.index)
                        }
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: action.modelData.label
                        color: action.current ? Theme.text : Theme.textMuted
                    }
                }
            }
        }
    }
}
