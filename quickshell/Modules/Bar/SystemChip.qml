import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// A single quiet glyph; tints when the machine is busy. Hover for live graphs.
BarChip {
    id: root

    readonly property bool busy: System.cpu > 0.8 || System.mem > 0.9 || System.temp > 85

    // Shown only under load. Collapse: hidden from level 4.
    wanted: busy
    widthAt: l => l >= 4 ? 0 : implicitWidth

    Icon {
        glyph: "memory"
    }

    // `ps` and the extra reads run only while the card is open.
    Binding {
        target: System
        property: "tracking"
        value: card.open
    }

    Popover {
        id: card

        target: root
        shown: root.hovered
        interactive: true       // has Kill buttons: stays open under the pointer
        cardWidth: Theme.popoverWidth

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.gapInline

            Icon {
                glyph: "memory"
                color: Theme.textMuted
            }

            Label {
                Layout.fillWidth: true
                text: "System"
                font.weight: Theme.weightEmphasis
            }

            Label {
                text: "Up " + System.formatUptime(System.uptime)
                font.features: { "tnum": 1 }
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }
        }

        StatRow {
            Layout.topMargin: Theme.spaceXs
            name: "CPU  ·  " + Math.round(System.temp) + "°C"
            value: Math.round(System.cpu * 100) + "%"
            history: System.cpuHistory
            color: Theme.text
        }

        StatRow {
            name: "Memory" + (System.swapTotal > 0 ? "  ·  Swap " + System.swapUsed.toFixed(1) + " GiB" : "")
            value: System.memUsed.toFixed(1) + " / " + System.memTotal.toFixed(1) + " GiB"
            history: System.memHistory
            color: Theme.text
        }

        StatRow {
            name: "Network  ·  ↑ " + System.formatRate(System.netUp)
            value: "↓ " + System.formatRate(System.netDown)
            history: System.netDownHistory
            maxValue: 0
            color: Theme.text
        }

        // Sensors found by name at runtime; rows hide when the machine lacks them.
        Repeater {
            model: System.sensors

            InfoRow {
                required property var modelData
                required property int index

                Layout.topMargin: index === 0 ? Theme.spaceXs : 0
                label: modelData.name + " temperature"
                value: Math.round(modelData.temp) + "°C"
                mono: true
            }
        }

        InfoRow {
            visible: System.fanRpm >= 0
            label: "Fan"
            value: System.fanRpm + " rpm"
            mono: true
        }

        InfoRow {
            label: "Load"
            value: System.load.toFixed(2)
            mono: true
        }

        Label {
            Layout.topMargin: Theme.spaceXs
            visible: System.procs.length > 0
            text: "Busiest processes"
            color: Theme.textMuted
            font.pixelSize: Theme.textXs
        }

        Repeater {
            model: System.procs

            RowLayout {
                required property var modelData

                Layout.fillWidth: true
                spacing: Theme.gapInline

                Label {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: modelData.name
                }

                Label {
                    text: Math.round(modelData.cpu * 100) + "%"
                    font.features: {
                        "tnum": 1
                    }
                    font.pixelSize: Theme.textSm
                    color: Theme.textMuted
                }

                // Sends SIGTERM (a polite quit); no pill for session-critical processes.
                Clickable {
                    visible: System.canKill(modelData)
                    implicitWidth: killLabel.implicitWidth + Theme.padControl * 2
                    implicitHeight: Theme.controlSm
                    radius: Theme.radiusFull
                    color: pressed ? Theme.pressed : hovered ? Qt.alpha(Theme.error, 0.24) : Qt.alpha(Theme.error, 0.14)
                    onClicked: System.kill(modelData)

                    Label {
                        id: killLabel

                        anchors.centerIn: parent
                        text: "Quit"
                        color: Theme.error
                        font.pixelSize: Theme.textXs
                    }
                }
            }
        }
    }
}
