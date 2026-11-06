import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

// One playing app: its icon and name over its own volume slider.
ColumnLayout {
    id: root

    required property var node

    spacing: Theme.spaceXs

    RowLayout {
        Layout.leftMargin: Theme.spaceXs
        spacing: Theme.gapInline

        IconImage {
            visible: source !== ""
            implicitSize: Theme.icon
            source: Audio.streamIcon(root.node)
        }

        Label {
            Layout.fillWidth: true
            text: Audio.streamName(root.node)
            font.pixelSize: Theme.textSm
        }
    }

    Slider {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.control
        value: root.node.audio.volume
        glyph: root.node.audio.muted ? "󰝟" : "󰕾"
        dimmed: root.node.audio.muted
        onMoved: v => {
            root.node.audio.muted = false;
            root.node.audio.volume = v;
        }
        onIconClicked: root.node.audio.muted = !root.node.audio.muted
    }
}
