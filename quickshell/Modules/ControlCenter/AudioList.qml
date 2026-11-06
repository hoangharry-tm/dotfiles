import QtQuick
import QtQuick.Layouts
import qs.Services
import qs.Widgets

// Pick the default output (speakers/headphones) or input (microphone).
DetailList {
    id: root

    property bool output: true
    readonly property var nodes: output ? Audio.sinks : Audio.sources
    readonly property var current: output ? Audio.sink : Audio.source

    title: output ? "Sound output" : "Sound input"
    count: nodes.length
    emptyText: "No devices"

    Repeater {
        model: root.nodes

        ListRow {
            required property var modelData

            Layout.fillWidth: true
            glyph: root.output ? (Audio.nameOf(modelData).match(/head|ear|buds/i) ? "󰋋" : "󰓃") : "󰍬"
            title: Audio.nameOf(modelData)
            trailingGlyph: modelData === root.current ? "󰄬" : ""
            selected: modelData === root.current
            onClicked: root.output ? Audio.setSink(modelData) : Audio.setSource(modelData)
        }
    }
}
