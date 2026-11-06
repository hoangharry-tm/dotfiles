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
    // Keyed on the app id string, not the window object: niri re-emits the
    // window on every title change (terminal spinners tick ~1 Hz), and the
    // fuzzy desktop-entry lookup must not rerun for each one.
    readonly property string appId: window?.app_id ?? ""
    readonly property var entry: appId ? DesktopEntries.heuristicLookup(appId) : null

    spacing: Theme.gapInline
    visible: window !== null

    IconImage {
        Layout.leftMargin: Theme.padControl
        Layout.preferredWidth: Theme.icon
        Layout.preferredHeight: Theme.icon
        source: Quickshell.iconPath(root.entry?.icon ?? root.appId, "application-x-executable")
    }

    Label {
        Layout.fillWidth: true
        Layout.maximumWidth: 300
        text: root.window?.title ?? ""
        color: Theme.textMuted
    }
}
