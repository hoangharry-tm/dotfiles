import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Phone / Mac link (KDE Connect). Hidden until a device is known; tap a
// device for its actions. The parent row is titled "Devices", so no heading.
// Rows hang by the well's padding so their wash meets the well edges while
// their content stays on column A.
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
                Layout.leftMargin: -root.pad
                Layout.rightMargin: -root.pad
                glyph: Glyphs.device(entry.modelData)
                title: entry.modelData.name
                subtitle: Devices.state(entry.modelData)
                trailingGlyph: !entry.modelData.paired ? "link" : root.open === entry.modelData.id ? "expand_less" : "expand_more"
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
                        { glyph: "content_paste", label: "Clipboard", cmd: "clipboard" },
                        { glyph: "upload_file", label: "File", cmd: "send-file" },
                        { glyph: "notifications", label: "Ping", cmd: "ping" }
                    ]

                    Button {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        variant: "tonal"
                        glyph: modelData.glyph
                        text: modelData.label
                        onClicked: modelData.cmd === "send-file" ? Devices.sendFile(entry.modelData.id) : Devices.run(modelData.cmd, entry.modelData.id)
                    }
                }
            }
        }
    }
}
