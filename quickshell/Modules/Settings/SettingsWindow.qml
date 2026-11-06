import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Widgets

// Settings: categories on the left, grouped rows on the right. A centred
// glass sheet (no anchors = centred by the compositor); Esc or a click
// outside (Scrim) closes it. Every control writes Services/Settings and
// applies live. Nix-owned values are read-only (see NixNote).
PanelWindow {
    id: root

    required property ShellScreen modelData
    readonly property bool shown: Panels.isOpen("settings", modelData.name)

    readonly property var categories: [
        { glyph: "󰒓", title: "General", page: "GeneralPage" },
        { glyph: "󰸉", title: "Appearance", page: "AppearancePage" },
        { glyph: "󰕮", title: "Bar", page: "BarPage" },
        { glyph: "󰂚", title: "Notifications & Focus", page: "NotificationsPage" },
        { glyph: "󰖔", title: "Night Light", page: "NightLightPage" },
        { glyph: "󰍎", title: "Location & Weather", page: "LocationPage" },
        { glyph: "󰎆", title: "Media", page: "MediaPage" },
        { glyph: "󰐥", title: "Power & Idle", page: "PowerPage" },
        { glyph: "󰋽", title: "About", page: "AboutPage" }
    ]
    property int category: 0

    screen: modelData
    // Mapped only while shown; the sheet is never faded or scaled so niri's
    // blur and shadow stay in step (DESIGN.md "Elevation").
    visible: shown
    implicitWidth: Math.min(Theme.launcherWidth + Theme.panelWidth, modelData.width - Theme.space2xl * 2)
    implicitHeight: Math.min(Theme.launcherWidth, modelData.height - Theme.space2xl * 2)
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.namespace: "qs-settings"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Glass {
        anchors.fill: parent
        radius: Theme.radiusXl // = qs-settings layer rule in niri/rules.kdl

        FocusScope {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: Panels.close()

            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.padSheet
                spacing: Theme.gapSection

                // Sidebar
                ColumnLayout {
                    Layout.preferredWidth: Theme.panelWidth / 2 + Theme.space2xl
                    Layout.maximumWidth: Theme.panelWidth / 2 + Theme.space2xl
                    Layout.fillHeight: true
                    spacing: Theme.spaceXs

                    Label {
                        Layout.leftMargin: Theme.spaceMd
                        Layout.bottomMargin: Theme.spaceSm
                        Layout.preferredHeight: Theme.controlLg
                        text: "Settings"
                        font.pixelSize: Theme.textXl
                        font.weight: Font.DemiBold
                    }

                    Repeater {
                        model: root.categories

                        ListRow {
                            id: item

                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            glyph: modelData.glyph
                            title: modelData.title
                            selected: index === root.category
                            onClicked: root.category = index
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }

                // Content
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0 // take what the sidebar leaves, not content size
                    Layout.fillHeight: true
                    spacing: Theme.gapSection

                    Label {
                        Layout.preferredHeight: Theme.controlLg
                        text: root.categories[root.category].title
                        font.pixelSize: Theme.textXl
                        font.weight: Font.DemiBold
                    }

                    Flickable {
                        id: scroller

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: page.item ? page.item.implicitHeight : 0
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        // One page alive at a time; a page loads its data when created.
                        Loader {
                            id: page

                            width: scroller.width
                            source: root.categories[root.category].page + ".qml"
                            onLoaded: scroller.contentY = 0
                        }
                    }
                }
            }
        }
    }
}
