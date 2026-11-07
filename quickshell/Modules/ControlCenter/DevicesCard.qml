import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Phone / Mac link (KDE Connect). Hidden until a device is known; tap a
// device for its actions. Battery shows only when the device reports it.
Section {
    id: root

    property string open: ""            // id of the expanded device
    property bool live: false           // Control Center open: allow refreshing

    visible: Devices.any
    Binding {
        target: Devices
        property: "active"
        value: root.live
    }

    Label {
        Layout.leftMargin: Theme.spaceMd
        text: "Devices"
        font.weight: Font.DemiBold
    }

    Repeater {
        model: Devices.list

        ColumnLayout {
            id: entry

            required property var modelData
            readonly property bool usable: modelData.paired && modelData.reachable

            Layout.fillWidth: true
            spacing: Theme.spaceXs

            ListRow {
                Layout.fillWidth: true
                glyph: Devices.icon(entry.modelData)
                title: entry.modelData.name
                subtitle: Devices.state(entry.modelData)
                selected: entry.usable
                trailingGlyph: !entry.modelData.paired ? "󰌷" : root.open === entry.modelData.id ? "󰅃" : "󰅀"
                onClicked: {
                    if (!entry.modelData.paired)
                        Devices.run("pair", entry.modelData.id);
                    else if (entry.usable)
                        root.open = root.open === entry.modelData.id ? "" : entry.modelData.id;
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: entry.usable && root.open === entry.modelData.id
                spacing: Theme.gapStack

                Repeater {
                    model: [
                        { glyph: "󰅍", label: "Clipboard", cmd: "clipboard" },
                        { glyph: "󰈔", label: "File", cmd: "send-file" },
                        { glyph: "󰂚", label: "Ping", cmd: "ping" }
                    ]

                    Clickable {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        implicitHeight: Theme.control
                        radius: Theme.radiusSm
                        onClicked: modelData.cmd === "send-file" ? Devices.sendFile(entry.modelData.id) : Devices.run(modelData.cmd, entry.modelData.id)

                        Row {
                            anchors.centerIn: parent
                            spacing: Theme.gapInline

                            Icon {
                                glyph: modelData.glyph
                                color: Theme.primary
                            }

                            Label {
                                text: modelData.label
                                font.pixelSize: Theme.textSm
                            }
                        }
                    }
                }
            }
        }
    }
}
