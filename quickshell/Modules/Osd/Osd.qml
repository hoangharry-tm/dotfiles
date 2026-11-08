import QtQuick
import QtQuick.Layouts
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
    // Held true across repeated presses: restart() briefly stops the timer,
    // so binding visibility to hide.running replayed the entrance each press.
    property bool shown: false

    function show(g, v, withValue) {
        if (!ready)
            return;
        glyph = g;
        value = v;
        showValue = withValue !== false;
        shown = true;
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
        onTriggered: root.shown = false
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
            root.show("brightness_medium", Brightness.value);
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: osd

            required property ShellScreen modelData

            screen: modelData
            visible: root.shown && Panels.focusedScreen() === modelData.name
            anchors.bottom: true
            margins.bottom: Theme.space2xl * 2
            implicitWidth: root.showValue ? Theme.popoverWidth - Theme.space2xl : Theme.fieldHeight
            implicitHeight: Theme.fieldHeight
            exclusiveZone: 0
            color: "transparent"
            WlrLayershell.namespace: "qs-osd"
            WlrLayershell.layer: WlrLayer.Overlay

            Glass {
                anchors.fill: parent
                radius: Theme.fieldHeight / 2 // pill; = qs-osd layer rule

                // symbol + thin track + tabular %: calm and neutral, never coloured
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: root.showValue ? Theme.spaceXl : 0
                    anchors.rightMargin: root.showValue ? Theme.spaceXl : 0
                    spacing: Theme.gapInline

                    Icon {
                        Layout.alignment: Qt.AlignVCenter | (root.showValue ? Qt.AlignLeft : Qt.AlignHCenter)
                        Layout.fillWidth: !root.showValue
                        glyph: root.glyph
                        size: Theme.iconLg
                        filled: true

                        // Content eases in (the pill is a glass sheet: not animated).
                        Enter {
                            active: osd.visible
                        }
                    }

                    Surface {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.trackHeight
                        visible: root.showValue
                        radius: Theme.radiusFull
                        variant: "track"

                        Enter {
                            active: osd.visible
                            index: 1
                        }

                        Surface {
                            width: Math.max(height, parent.width * Math.min(1, root.value))
                            height: parent.height
                            radius: Theme.radiusFull
                            variant: "solid"

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
                        visible: root.showValue
                        Layout.preferredWidth: Theme.control
                        horizontalAlignment: Text.AlignRight
                        text: Math.round(root.value * 100)
                        font.pixelSize: Theme.textXs
                        font.features: {
                            "tnum": 1
                        }
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
}
