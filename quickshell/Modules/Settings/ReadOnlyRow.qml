import QtQuick
import qs.Common
import qs.Widgets

// A fixed value (muted, right-aligned) for read-only information.
SettingRow {
    id: root

    property string value: ""

    Label {
        text: root.value
        color: Theme.textMuted
        font.family: Theme.mono
        font.pixelSize: Theme.textSm
    }
}
