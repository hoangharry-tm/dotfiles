import QtQuick
import QtQuick.Layouts
import qs.Services
import qs.Widgets

// Pick the default output (speakers/headphones) or input (microphone).
// Extra children (the mic level) follow the device rows inside the group.
ListBlock {
    id: root

    property bool output: true
    readonly property var nodes: output ? Audio.sinks : Audio.sources
    readonly property var current: output ? Audio.sink : Audio.source

    count: nodes.length
    heading: output ? "Output" : "Input"
    empty: nodes.length === 0
    emptyText: "No devices"

    Repeater {
        model: root.nodes

        ListRow {
            required property var modelData

            Layout.fillWidth: true
            glyph: root.output ? (Audio.nameOf(modelData).match(/head|ear|buds/i) ? "headphones" : "volume_up") : "mic"
            title: Audio.nameOf(modelData)
            marked: modelData === root.current
            onClicked: root.output ? Audio.setSink(modelData) : Audio.setSource(modelData)
        }
    }
}
