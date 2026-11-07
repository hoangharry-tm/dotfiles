import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

// "Updates: 42 changes" from the weekly `updates` check (flake update in a
// scratch copy; nothing is applied). Tap the row to list what would change;
// "Check now" runs the check immediately.
Section {
    id: root

    property bool open: false
    property real now: Date.now() / 1000

    function ago(secs) {
        if (secs <= 0)
            return "never";
        const d = Math.max(0, root.now - secs);
        if (d < 3600)
            return "just now";
        if (d < 86400)
            return Math.floor(d / 3600) + " h ago";
        return Math.floor(d / 86400) + " d ago";
    }

    Timer {
        interval: 60000
        running: root.visible
        repeat: true
        onTriggered: root.now = Date.now() / 1000
    }

    Clickable {
        Layout.fillWidth: true
        implicitHeight: Theme.control
        onClicked: root.open = !root.open && Updates.count > 0

        RowLayout {
            anchors.fill: parent
            spacing: Theme.gapInline

            InfoRow {
                glyph: !Updates.ok ? "󰀦" : "󰚰"
                label: "Updates"
                value: !Updates.known ? "not checked" : !Updates.ok ? "check failed" : Updates.count === 0 ? "up to date" : Updates.count + " changes"
                valueColor: !Updates.ok ? Theme.error : Theme.text
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.gapInline

        Label {
            Layout.fillWidth: true
            elide: Text.ElideRight
            color: Theme.textMuted
            font.pixelSize: Theme.textSm
            text: !Updates.known ? "Weekly, on AC power" : "Checked " + root.ago(Updates.checkedAt) + (Updates.nixpkgsDays >= 0 ? "  ·  nixpkgs " + Updates.nixpkgsDays + " d old" : "")
        }

        Clickable {
            implicitWidth: checkLabel.implicitWidth + Theme.padControl * 2
            implicitHeight: Theme.control - Theme.spaceSm
            radius: Theme.radiusFull
            color: pressed ? Theme.pressed : hovered ? Theme.hover : Theme.surfaceHigh
            enabled: !Updates.checking
            onClicked: Updates.check()

            Label {
                id: checkLabel

                anchors.centerIn: parent
                text: Updates.checking ? "Checking…" : "Check now"
                font.pixelSize: Theme.textSm
            }
        }
    }

    Label {
        visible: root.visible && Updates.known && !Updates.ok
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        maximumLineCount: 3
        elide: Text.ElideRight
        text: Updates.message
        color: Theme.error
        font.pixelSize: Theme.textXs
    }

    ColumnLayout {
        visible: root.open && Updates.count > 0
        Layout.fillWidth: true
        spacing: Theme.spaceXs

        Repeater {
            model: Updates.summary

            Label {
                required property string modelData

                Layout.fillWidth: true
                elide: Text.ElideRight
                text: modelData
                font.family: Theme.mono
                font.pixelSize: Theme.textXs
                color: Theme.textMuted
            }
        }

        Label {
            Layout.fillWidth: true
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
            text: "Apply: nix flake update && nh home switch"
        }
    }
}
