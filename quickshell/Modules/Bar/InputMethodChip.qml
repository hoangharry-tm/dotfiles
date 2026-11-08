import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

// Active input method (VI, ...) for fcitx5; click toggles. Shown only when it
// is not the default (first) layout, so the resting bar stays empty.
BarChip {
    id: root

    // Collapse: hidden from level 3.
    wanted: Ime.running && Ime.vietnamese
    widthAt: l => l >= 3 ? 0 : implicitWidth
    onClicked: Ime.toggle()

    Label {
        text: Ime.label
        font.pixelSize: Theme.textSm
        font.weight: Theme.weightEmphasis
    }
}
