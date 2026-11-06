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

    spacing: 8
    visible: window !== null

    IconImage {
        Layout.preferredWidth: 16
        Layout.preferredHeight: 16
        source: Quickshell.iconPath(root.entry?.icon ?? root.window?.app_id ?? "", "application-x-executable")
    }

    Label {
        Layout.fillWidth: true
        Layout.maximumWidth: 300
        text: root.window?.title ?? ""
        color: Theme.textMuted
    }
}
