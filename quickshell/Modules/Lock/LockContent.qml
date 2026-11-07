import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

// One screen of the lock screen: blurred wallpaper, clock, glass password
// pill, now-playing line and notification count. Shared by the real session
// lock and the preview window.
Item {
    id: root

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

    // Scrim keeps text legible on bright wallpapers.
    Rectangle {
        anchors.fill: parent
        color: Theme.scrim
    }

    // Slow light drift + grain over the blurred wallpaper (shaders/lock-drift.frag,
    // built by modules/motion.nix). Balanced/high tier, on AC only, <= 30 fps,
    // and it stops after driftIdle without pointer activity (an unattended or
    // dimmed screen costs nothing); moving the pointer resumes it.
    Loader {
        id: drift

        property bool awake: true

        anchors.fill: parent
        active: awake && Theme.motionAmbient && !PowerMode.lowPower && (Power.plugged || !Power.hasBattery)

        sourceComponent: ShaderEffect {
            property real time: 0
            property real aspect: width / Math.max(1, height)
            property real strength: Theme.motionRich ? 1 : 0.7

            fragmentShader: "file://" + Quickshell.env("HOME") + "/.local/share/motion/lock-drift.frag.qsb"
            blending: true

            Timer {
                interval: 1000 / 30
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

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.gapSection

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatTime(clock.date, "HH:mm")
            font.pixelSize: Theme.textDisplay
            font.weight: Font.Light
            color: Theme.text
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDate(clock.date, "dddd, d MMMM")
            font.pixelSize: Theme.textXl
            color: Theme.textMuted
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
                glyph: Lock.busy ? "󰔟" : "󰌆"
                size: Theme.iconLg
                color: Lock.failures > 0 && !Lock.busy ? Theme.error : Theme.textMuted
            }

            TextInput {
                id: input

                anchors.left: lockIcon.right
                anchors.leftMargin: Theme.gapInline
                anchors.right: parent.right
                anchors.rightMargin: Theme.padCard
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: Theme.textLg
                echoMode: TextInput.Password
                passwordCharacter: "•"
                enabled: !Lock.busy
                clip: true
                selectionColor: Theme.selection

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
            color: Lock.failures > 0 && !Lock.busy ? Theme.error : Theme.textMuted
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
                glyph: Media.playing ? "󰎇" : "󰏤"
                color: Theme.textMuted
            }

            Label {
                Layout.maximumWidth: Theme.launcherWidth
                text: Media.artist !== "" ? Media.title + " · " + Media.artist : Media.title
                color: Theme.textMuted
                font.pixelSize: Theme.textMd
            }
        }

        RowLayout {
            visible: Notifications.history.length > 0
            spacing: Theme.gapInline

            Icon {
                glyph: "󰂚"
                color: Theme.textMuted
            }

            Label {
                text: Notifications.history.length
                color: Theme.textMuted
                font.pixelSize: Theme.textMd
            }
        }
    }
}
