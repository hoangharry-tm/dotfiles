import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services

ColumnLayout {
    spacing: Theme.gapSection

    Group {
        title: "Now playing"

        SettingRow {
            title: "Keep after pause"
            subtitle: "How long the player stays in the bar and Control Center"

            SettingSlider {
                from: 0
                to: 30
                step: 1
                current: Settings.mediaGraceMs / 1000
                suffix: " s"
                onPicked: v => Settings.mediaGraceMs = v * 1000
            }
        }

        ReadOnlyRow {
            title: "Player"
            value: Media.active ? Media.title : "nothing playing"
        }
    }
}
