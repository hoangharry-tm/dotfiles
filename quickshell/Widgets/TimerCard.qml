import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services

// The Focus-timer card, shared by the bar chip's popover and the top-centre
// panel: a thin tabular time inside a progress ring, -/+ to either side, preset
// chips, then Reset and Play/Pause. The length is editable whenever the timer
// is not running: click the time to type minutes or mm:ss, or hold -/+ to repeat
// (no scroll-to-adjust: too easy to change by accident).
ColumnLayout {
    id: root

    readonly property bool editable: !FocusTimer.running
    property bool editing: false
    readonly property var presets: [5, 15, 25, 45, 60]

    signal started

    spacing: Theme.spaceLg
    implicitWidth: Theme.popoverWidth - Theme.padCard * 2

    // Seconds tick only while this card is on screen.
    onVisibleChanged: FocusTimer.secWatchers += visible ? 1 : -1
    Component.onCompleted: if (visible)
        FocusTimer.secWatchers++
    Component.onDestruction: if (visible)
        FocusTimer.secWatchers--
    onEditableChanged: if (!editable)
        editing = false

    function commit(text) {
        const t = text.trim();
        const parts = t.split(":");
        const m = parts.length > 1 ? (parseFloat(parts[0]) || 0) + (parseFloat(parts[1]) || 0) / 60 : parseFloat(t);
        if (m > 0)
            FocusTimer.setMinutes(m);
        editing = false;
    }

    // Round icon button. `filled` is the card's one primary action; `repeat`
    // fires on press and again while held (after a short delay).
    component RoundButton: Clickable {
        id: btn

        property string glyph
        property bool filled: false
        property bool repeat: false

        signal activated

        implicitWidth: filled ? Theme.controlXl : Theme.controlLg
        implicitHeight: implicitWidth
        radius: Theme.radiusFull
        opacity: enabled ? 1 : 0.4
        onClicked: if (!repeat)
            activated()
        onPressedChanged: if (repeat && pressed) {
            activated();
            hold.interval = Theme.holdDelay;
        }

        Timer {
            id: hold

            interval: Theme.holdDelay
            repeat: true
            running: btn.repeat && btn.pressed
            onTriggered: {
                interval = Theme.holdRepeat;
                btn.activated();
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            z: -1
            color: btn.filled ? Theme.primary : Theme.tile
            opacity: btn.filled && btn.hovered ? 0.9 : 1
        }

        Icon {
            anchors.centerIn: parent
            glyph: btn.glyph
            size: btn.filled ? Theme.iconXl : Theme.iconLg
            color: btn.filled ? Theme.onAccent : Theme.text
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Theme.gapInline

        RoundButton {
            glyph: "remove"
            repeat: true
            enabled: root.editable
            opacity: root.editable ? 1 : 0 // keeps the ring centred while running
            onActivated: FocusTimer.stepMinutes(-1)
        }

        Item {
            implicitWidth: Theme.timerRing
            implicitHeight: Theme.timerRing

            ProgressRing {
                anchors.fill: parent
                value: FocusTimer.fraction
                lineWidth: Theme.spaceXs
                tone: FocusTimer.paused ? Theme.textMuted : Theme.primary
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0

                Clickable {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: Math.max(clock.implicitWidth, field.implicitWidth) + Theme.spaceSm * 2
                    implicitHeight: clock.implicitHeight + Theme.spaceXs * 2
                    enabled: root.editable
                    cursor: Qt.IBeamCursor
                    onClicked: {
                        root.editing = true;
                        field.text = String(Math.round(FocusTimer.remainingMs / 6000) / 10);
                        field.forceActiveFocus();
                        field.selectAll();
                    }

                    Label {
                        id: clock

                        anchors.centerIn: parent
                        visible: !root.editing
                        text: FocusTimer.clockText
                        color: FocusTimer.paused ? Theme.textMuted : Theme.text
                        font.pixelSize: Theme.textTimer
                        font.weight: Font.Light
                        font.features: { "tnum": 1 }
                    }

                    Input {
                        id: field

                        anchors.centerIn: parent
                        visible: root.editing
                        width: Theme.timerRing - Theme.space2xl
                        horizontalAlignment: TextInput.AlignHCenter
                        color: Theme.primary
                        selectedTextColor: Theme.text
                        font.pixelSize: Theme.textTimer
                        font.weight: Font.Light
                        font.features: { "tnum": 1 }
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        validator: RegularExpressionValidator {
                            regularExpression: /[0-9:.]*/
                        }
                        onAccepted: root.commit(text)
                        Keys.onEscapePressed: root.editing = false
                        onActiveFocusChanged: if (!activeFocus)
                            root.editing = false
                    }
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.editing ? "min or mm:ss" : FocusTimer.running ? "Focus on" : FocusTimer.paused ? "Paused" : "Ready"
                    color: Theme.textMuted
                    font.pixelSize: Theme.textXs
                }
            }
        }

        RoundButton {
            glyph: "add"
            repeat: true
            enabled: root.editable
            opacity: root.editable ? 1 : 0
            onActivated: FocusTimer.stepMinutes(1)
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.editable
        spacing: Theme.spaceSm

        Repeater {
            model: root.presets

            Clickable {
                id: chip

                required property int modelData
                readonly property bool current: Math.abs(FocusTimer.durationMs / 60000 - modelData) < 0.01

                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: Theme.controlSm
                radius: Theme.radiusFull
                color: current ? Theme.selection : hovered ? Theme.hover : Theme.tile
                onClicked: FocusTimer.setMinutes(modelData)

                Label {
                    anchors.centerIn: parent
                    text: chip.modelData
                    font.pixelSize: Theme.textXs
                    font.features: { "tnum": 1 }
                }
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Theme.spaceLg

        RoundButton {
            glyph: "restart_alt"
            enabled: FocusTimer.active
            onActivated: FocusTimer.reset()
        }

        RoundButton {
            filled: true
            glyph: FocusTimer.running ? "pause" : "play_arrow"
            onActivated: {
                const wasIdle = !FocusTimer.active;
                root.editing = false;
                FocusTimer.toggle();
                if (wasIdle)
                    root.started();
            }
        }
    }

    Label {
        Layout.fillWidth: true
        visible: FocusTimer.todayCount > 0
        horizontalAlignment: Text.AlignHCenter
        text: FocusTimer.todayCount + " completed today"
        color: Theme.textMuted
        font.pixelSize: Theme.textXs
    }
}
