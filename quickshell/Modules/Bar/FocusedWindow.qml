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

    // Responsive hooks (see ResponsiveRow). The title is elastic (it elides
    // first), so its planning width is only its minimum: icon + a short stub.
    property int level: 0
    readonly property bool wanted: window !== null
    readonly property real minWidth: Theme.padControl + Theme.icon + Theme.gapInline + Theme.control * 3
    readonly property var widthAt: l => minWidth

    spacing: Theme.gapInline
    visible: wanted

    IconImage {
        Layout.leftMargin: Theme.padControl
        Layout.preferredWidth: Theme.icon
        Layout.preferredHeight: Theme.icon
        source: Quickshell.iconPath(root.entry?.icon ?? root.appId, "application-x-executable")
    }

    Label {
        Layout.fillWidth: true
        Layout.maximumWidth: 300 // content cap
        Layout.minimumWidth: 0
        text: root.window?.title ?? ""
        color: Theme.textMuted
    }
}
