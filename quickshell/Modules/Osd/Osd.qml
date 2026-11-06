import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services
import qs.Widgets

// On-screen indicator for volume, mic mute and brightness changes: a glass
// pill near the bottom of the focused screen that fades out.
Scope {
    id: root

    property string glyph: ""
    property real value: 0
    property bool showValue: true
    property bool ready: false        // ignore the initial values at startup

    function show(g, v, withValue) {
        if (!ready)
            return;
        glyph = g;
        value = v;
        showValue = withValue !== false;
        hide.restart();
    }

    Timer {
        interval: 1500
        running: true
        onTriggered: root.ready = true
    }

    Timer {
        id: hide

        interval: 1400
    }

    Connections {
        target: Audio

        // Muted reads as empty, like macOS.
        function onVolumeChanged() {
            root.show(Audio.volumeIcon, Audio.muted ? 0 : Audio.volume);
        }

        function onMutedChanged() {
            root.show(Audio.volumeIcon, Audio.muted ? 0 : Audio.volume);
        }

        function onMicMutedChanged() {
            root.show(Audio.micIcon, 0, false);
        }
    }

    Connections {
        target: Brightness

        function onChangedByUser() {
            root.show("󰃠", Brightness.value);
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: osd

            required property ShellScreen modelData

            screen: modelData
            visible: hide.running && Panels.focusedScreen() === modelData.name
            anchors.bottom: true
            margins.bottom: 72
            implicitWidth: root.showValue ? 280 : 64
            implicitHeight: 52
            exclusiveZone: 0
            color: "transparent"
            WlrLayershell.namespace: "qs-osd"
            WlrLayershell.layer: WlrLayer.Overlay

            Glass {
                anchors.fill: parent
                radius: 26

                Icon {
                    id: icon

                    anchors.left: parent.left
                    anchors.leftMargin: root.showValue ? 18 : 0
                    anchors.horizontalCenter: root.showValue ? undefined : parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: root.glyph
                    size: Theme.iconLg
                }

                Rectangle {
                    visible: root.showValue
                    anchors.left: icon.right
                    anchors.leftMargin: 14
                    anchors.right: percent.left
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    height: 6
                    radius: 3
                    color: Theme.tile

                    Rectangle {
                        width: parent.width * Math.min(1, root.value)
                        height: parent.height
                        radius: 3
                        color: Theme.primary

                        Behavior on width {
                            NumberAnimation {
                                duration: Theme.animFast
                            }
                        }
                    }
                }

                Label {
                    id: percent

                    visible: root.showValue
                    anchors.right: parent.right
                    anchors.rightMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    width: 34
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(root.value * 100)
                    font.family: Theme.mono
                    font.pixelSize: Theme.textSm
                    color: Theme.textMuted
                }
            }
        }
    }
}
