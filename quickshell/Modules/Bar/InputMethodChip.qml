import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

// EN / VI indicator for fcitx5; click toggles. Hidden when fcitx5 is down.
BarChip {
    id: root

    // Collapse: hidden from level 6.
    wanted: Ime.running
    widthAt: l => l >= 6 ? 0 : implicitWidth
    onClicked: Ime.toggle()

    Label {
        text: Ime.label
        font.pixelSize: Theme.textSm
        font.weight: Font.DemiBold
        color: Ime.vietnamese ? Theme.primary : Theme.textMuted
    }
}
