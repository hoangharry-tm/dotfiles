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
            margins.bottom: Theme.space2xl * 2
            implicitWidth: root.showValue ? 280 : Theme.fieldHeight
            implicitHeight: Theme.fieldHeight
            exclusiveZone: 0
            color: "transparent"
            WlrLayershell.namespace: "qs-osd"
            WlrLayershell.layer: WlrLayer.Overlay

            Glass {
                anchors.fill: parent
                radius: Theme.fieldHeight / 2 // pill; = qs-osd layer rule

                Icon {
                    id: icon

                    anchors.left: parent.left
                    anchors.leftMargin: root.showValue ? Theme.spaceXl : 0
                    anchors.horizontalCenter: root.showValue ? undefined : parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: root.glyph
                    size: Theme.iconLg

                    // Content eases in (the pill is a glass sheet: not animated).
                    Enter {
                        active: osd.visible
                    }
                }

                Rectangle {
                    visible: root.showValue
                    anchors.left: icon.right
                    anchors.leftMargin: Theme.spaceMd
                    anchors.right: percent.left
                    anchors.rightMargin: Theme.spaceMd
                    anchors.verticalCenter: parent.verticalCenter
                    height: Theme.trackHeight
                    radius: Theme.trackHeight / 2
                    color: Theme.tile

                    Enter {
                        active: osd.visible
                        index: 1
                    }

                    Rectangle {
                        width: parent.width * Math.min(1, root.value)
                        height: parent.height
                        radius: Theme.trackHeight / 2
                        color: Theme.primary

                        Behavior on width {
                            NumberAnimation {
                                duration: Theme.animFast
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Theme.curveDecelerate
                            }
                        }
                    }
                }

                Label {
                    id: percent

                    visible: root.showValue
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spaceXl
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.spaceXl + Theme.spaceSm
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(root.value * 100)
                    font.family: Theme.mono
                    font.pixelSize: Theme.textXs
                    color: Theme.textMuted

                    Enter {
                        active: osd.visible
                        index: 2
                    }
                }
            }
        }
    }
}
