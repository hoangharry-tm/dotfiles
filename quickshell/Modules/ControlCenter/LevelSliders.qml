import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services

// Display and sound levels; the volume chevron opens the sound list.
ColumnLayout {
    id: root

    required property var cc

    spacing: Theme.gapStack

    SliderRow {
        Layout.fillWidth: true
        visible: Brightness.available
        value: Brightness.value
        glyph: "brightness_6"
        expandable: false
        onMoved: v => Brightness.set(v)
    }

    SliderRow {
        Layout.fillWidth: true
        value: Audio.volume
        glyph: Audio.volumeIcon
        dimmed: Audio.muted
        expanded: root.cc.detail === "sound"
        onMoved: v => Audio.setVolume(v)
        onIconClicked: Audio.toggleMute()
        onExpand: root.cc.toggleDetail("sound")
    }

    Loader {
        Layout.fillWidth: true
        Layout.leftMargin: Theme.spaceMd // indented under its slider: a child
        active: root.cc.detail === "sound"
        visible: active
        sourceComponent: SoundList {}
    }
}
