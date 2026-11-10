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
        { glyph: "tune", title: "General", page: "GeneralPage" },
        { glyph: "palette", title: "Appearance", page: "AppearancePage" },
        { glyph: "dock_to_bottom", title: "Dock", page: "DockPage" },
        { glyph: "notifications", title: "Notifications & Focus", page: "NotificationsPage" },
        { glyph: "nightlight", title: "Night Light", page: "NightLightPage" },
        { glyph: "location_on", title: "Location & Weather", page: "LocationPage" },
        { glyph: "calendar_month", title: "Calendars", page: "CalendarPage" },
        { glyph: "battery_charging_full", title: "Power & Idle", page: "PowerPage" },
        { glyph: "info", title: "About", page: "AboutPage" }
    ]
    property int category: 0

    // Sheet proportion (DESIGN.md "Deliberate proportion"): width = height x
    // golden ratio, on the grid, both capped by the screen. Content keeps a
    // readable measure (launcherWidth) and sits left on column A.
    readonly property int sheetHeight: Math.min(Theme.settingsHeight, modelData.height - Theme.space2xl * 2)
    readonly property int sidebarWidth: Theme.panelWidth / 2 + Theme.space2xl
    readonly property int columnA: Theme.columnA

    screen: modelData
    // Mapped only while shown; the sheet is never faded or scaled so niri's
    // blur and shadow stay in step (DESIGN.md "Elevation").
    visible: shown
    implicitWidth: Math.min(Theme.grid(sheetHeight * Theme.ratio), modelData.width - Theme.space2xl * 2)
    implicitHeight: sheetHeight
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

                // Sidebar: one grouped list, monochrome symbols; the current
                // page is a neutral wash with a filled symbol, never accent.
                ColumnLayout {
                    Layout.preferredWidth: root.sidebarWidth
                    Layout.maximumWidth: root.sidebarWidth
                    Layout.fillHeight: true
                    spacing: Theme.spaceSm

                    Label {
                        Layout.leftMargin: root.columnA
                        Layout.preferredHeight: Theme.controlLg
                        text: "Settings"
                        font.pixelSize: Theme.textXl
                        font.weight: Theme.weightTitle
                    }

                    Group {
                        Layout.fillWidth: true

                        Repeater {
                            model: root.categories

                            ListRow {
                                required property var modelData
                                required property int index

                                Layout.fillWidth: true
                                glyph: modelData.glyph
                                title: modelData.title
                                selected: index === root.category
                                activeColor: Theme.fillOn
                                onClicked: root.category = index
                            }
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
                    spacing: Theme.spaceSm

                    Label {
                        Layout.leftMargin: root.columnA
                        Layout.preferredHeight: Theme.controlLg
                        text: root.categories[root.category].title
                        font.pixelSize: Theme.textXl
                        font.weight: Theme.weightTitle
                    }

                    Flickable {
                        id: scroller

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: page.item ? page.item.implicitHeight : 0
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        ScrollIndicator {
                            flick: scroller
                        }

                        // Hold presses briefly: a scroll/drag that starts on a control (power
                        // mode, tiles) must scroll the page, never land as a click on it.
                        pressDelay: Theme.pressDelay

                        SmoothWheel {
                            flick: scroller
                        }

                        // One page alive at a time; a page loads its data when created.
                        Loader {
                            id: page

                            width: Math.min(scroller.width, Theme.launcherWidth)
                            source: root.categories[root.category].page + ".qml"
                            onLoaded: scroller.contentY = 0
                        }
                    }
                }
            }
        }
    }
}
