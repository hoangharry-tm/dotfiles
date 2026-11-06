import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets

// App icon + title of the focused window.
RowLayout {
    id: root

    readonly property var window: Niri.focusedWindow
    readonly property var entry: window ? DesktopEntries.heuristicLookup(window.app_id) : null

    spacing: Theme.gapInline
    visible: window !== null

    IconImage {
        Layout.leftMargin: Theme.padControl
        Layout.preferredWidth: Theme.icon
        Layout.preferredHeight: Theme.icon
        source: Quickshell.iconPath(root.entry?.icon ?? root.window?.app_id ?? "", "application-x-executable")
    }

    Label {
        Layout.fillWidth: true
        Layout.maximumWidth: 300
        text: root.window?.title ?? ""
        color: Theme.textMuted
    }
}
