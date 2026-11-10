import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Desktop

// One screen of the lock screen: blurred wallpaper, clock, glass password
// pill, now-playing line and notification count. Shared by the real session
// lock and the preview window.
Item {
    id: root

    // Arrival and departure are one dissolve: the sharp wallpaper (what the
    // desktop shows) and the blurred lock image cross-fade, and the content
    // fades with them. `veil` is 1 when the screen looks like the desktop and
    // 0 when fully locked; it is 1 on creation (lock in), eases to 0, and goes
    // back to 1 while `leaving` (unlock). Content fades; no niri-blurred
    // sheet is involved here (the session lock has no layer rules).
    property bool leaving: false
    property bool entered: false
    property real veil: (leaving || !entered) ? 1 : 0

    Behavior on veil {
        NumberAnimation {
            duration: Theme.animSlow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.leaving ? Theme.curveAccelerate : Theme.curveDecelerate
        }
    }

    Component.onCompleted: Qt.callLater(() => root.entered = true)

    // Only the surface that has keyboard focus types; others mirror the dots.
    function focusInput() {
        input.forceActiveFocus();
    }

    // lock.jpg is pre-blurred by `wallpaper` (matugen step); fall back to the
    // flat surface colour if it is missing.
    Rectangle {
        anchors.fill: parent
        color: Theme.surface
    }

    Image {
        anchors.fill: parent
        source: "file://" + Quickshell.env("HOME") + "/.local/state/theme/lock.jpg"
        fillMode: Image.PreserveAspectCrop
        cache: false
        asynchronous: true
    }

    // The desktop's own wallpaper, sharp: visible only while the veil is up.
    Image {
        anchors.fill: parent
        source: "file://" + Quickshell.env("HOME") + "/.local/state/theme/wallpaper.jpg"
        fillMode: Image.PreserveAspectCrop
        cache: false
        asynchronous: true
        opacity: root.veil
    }

    // Scrim keeps image-ink legible: it pushes the image further the way the ink contrasts.
    Rectangle {
        anchors.fill: parent
        color: Theme.imageScrim
        opacity: 1 - root.veil
    }

    // Slow light drift + grain over the blurred wallpaper (shaders/lock-drift.frag,
    // built by modules/motion.nix). Balanced/high tier, on AC only, <= 30 fps,
    // and it stops after driftIdle without pointer activity (an unattended or
    // dimmed screen costs nothing); moving the pointer resumes it.
    Loader {
        id: drift

        property bool awake: true

        anchors.fill: parent
        opacity: 1 - root.veil
        active: awake && Theme.motionAmbient && !PowerMode.lowPower && (Power.plugged || !Power.hasBattery)

        sourceComponent: ShaderEffect {
            property real time: 0
            property real aspect: width / Math.max(1, height)
            property real strength: Theme.motionRich ? 1 : 0.7

            fragmentShader: "file://" + Quickshell.env("HOME") + "/.local/share/motion/lock-drift.frag.qsb"
            blending: true

            Timer {
                interval: 1000 / Theme.shaderFps
                repeat: true
                running: true
                onTriggered: parent.time += interval / 1000
            }
        }

        Timer {
            id: sleepy

            interval: Theme.driftIdle
            running: drift.awake
            onTriggered: drift.awake = false
        }

        HoverHandler {
            onPointChanged: {
                if (!drift.awake)
                    drift.awake = true;
                sleepy.restart();
            }
        }
    }

    // Content (clock, field, status) fades and rises with the veil.
    Item {
        anchors.fill: parent
        // Never exactly 0: an item at opacity 0 is invisible to Qt and drops
        // keyboard focus, and the field is focused before the fade-in starts.
        opacity: Math.max(0.001, 1 - root.veil)

        transform: Translate {
            y: root.veil * Theme.enterRise
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.gapSection

            // Same lockup as the desktop (bottom-left) and the greeter; centred
            // here because this is the one thing on the screen.
            ClockLockup {
                Layout.alignment: Qt.AlignHCenter
                ink: Theme.onImage
                inkMuted: Theme.onImageMuted
                alignment: Qt.AlignHCenter
            }

            Item {
                Layout.preferredHeight: Theme.space2xl
                Layout.preferredWidth: 1
            }

            // Password pill. Not a niri-blurred layer, so it may shake freely.
            Glass {
                id: pill

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Theme.popoverWidth
                Layout.preferredHeight: Theme.fieldHeight
                radius: Theme.radiusFull
                border.color: Lock.failures > 0 && !Lock.busy ? Theme.error : input.activeFocus ? Theme.primary : Theme.hairline

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
                    target: Lock

                    function onFailed() {
                        input.text = "";
                        shake.restart();
                        Qt.callLater(root.focusInput);
                    }
                }

                Icon {
                    id: lockIcon

                    anchors.left: parent.left
                    anchors.leftMargin: Theme.padCard
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: Lock.busy ? "hourglass_top" : "lock"
                    size: Theme.iconLg
                    color: Lock.failures > 0 && !Lock.busy ? Theme.error : Theme.textMuted
                }

                Input {
                    id: input

                    anchors.left: lockIcon.right
                    anchors.leftMargin: Theme.gapInline
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.padCard
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.textLg
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    enabled: !Lock.busy

                    Keys.onReturnPressed: Lock.submit(text)
                    Keys.onEnterPressed: Lock.submit(text)
                    Keys.onEscapePressed: {
                        if (Lock.preview)
                            Lock.locked = false; // preview only: a real lock ignores Esc
                        else
                            text = "";
                    }
                    onTextChanged: if (text !== "" && Lock.failures > 0 && !Lock.busy) Lock.message = ""

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: input.text === ""
                        text: "Password"
                        color: Theme.textMuted
                        font.pixelSize: Theme.textLg
                    }
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                // Reserve the line so the pill does not jump when an error shows.
                text: Lock.failures > 0 && !Lock.busy ? Lock.message : (Lock.preview ? "Preview: Esc closes" : " ")
                color: Lock.failures > 0 && !Lock.busy ? Theme.error : Theme.onImageMuted
                font.pixelSize: Theme.textXs
            }
        }

        // Status line: media and notification count, quiet at the bottom.
        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.space2xl
            spacing: Theme.gapSection

            RowLayout {
                visible: Media.shown
                spacing: Theme.gapInline

                Icon {
                    glyph: Media.playing ? "music_note" : "pause"
                    color: Theme.onImageMuted
                }

                Label {
                    Layout.maximumWidth: Theme.launcherWidth
                    text: Media.artist !== "" ? Media.title + " · " + Media.artist : Media.title
                    color: Theme.onImageMuted
                    font.pixelSize: Theme.textMd
                }
            }

            RowLayout {
                visible: Notifications.history.length > 0
                spacing: Theme.gapInline

                Icon {
                    glyph: "notifications"
                    color: Theme.onImageMuted
                }

                Label {
                    text: Notifications.history.length
                    font.features: { "tnum": 1 }
                    color: Theme.onImageMuted
                    font.pixelSize: Theme.textMd
                }
            }
        }
    }
}
