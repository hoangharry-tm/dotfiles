import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Common
import qs.Services

// Notifications of one app. Collapsed: the latest card on a stack of peeking
// layers plus "+N more" (click to expand). Expanded: every card. Non-toast
// groups get a header: app icon, name, collapse, clear group. Toasts are the
// compact, always-collapsed form.
Item {
    id: root

    required property string groupKey
    property bool toast: false
    // Toasts and the history read different indexes of the same service.
    readonly property var items: Notifications.itemsIn(toast ? Notifications.toastIndex : Notifications.historyIndex, groupKey)
    readonly property bool expandable: !toast && items.length > 1
    readonly property bool open: expandable && !!Notifications.expanded[groupKey]
    readonly property int hidden: items.length - 1
    readonly property int layers: Math.min(hidden, 2)
    property int busy: 0               // cards being hovered, dragged or typed in
    readonly property bool interacting: busy > 0
    readonly property string name: items.length > 0 ? (items[0].appName || groupKey) : groupKey

    implicitHeight: column.implicitHeight

    ColumnLayout {
        id: column

        width: parent.width
        spacing: Theme.gapStack

        // Header: app icon, name, collapse, clear group.
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spaceMd
            visible: !root.toast
            spacing: Theme.gapInline

            Item {
                Layout.preferredWidth: Theme.iconLg
                Layout.preferredHeight: Theme.iconLg

                readonly property string source: root.items.length > 0 ? Notifications.appIconOf(root.items[0]) : ""

                IconImage {
                    anchors.fill: parent
                    source: parent.source
                    visible: parent.source !== ""
                }

                Icon {
                    anchors.centerIn: parent
                    glyph: "󰂚"
                    visible: parent.source === ""
                }
            }

            Label {
                Layout.fillWidth: true
                text: root.name
                color: Theme.textMuted
                font.pixelSize: Theme.textSm
                font.weight: Font.DemiBold
            }

            Clickable {
                visible: root.expandable
                Layout.preferredHeight: Theme.controlSm
                Layout.preferredWidth: less.implicitWidth + Theme.padControl * 2
                radius: Theme.radiusFull
                onClicked: Notifications.toggleGroup(root.groupKey)

                Label {
                    id: less

                    anchors.centerIn: parent
                    text: root.open ? "Show less" : "Show all"
                    color: Theme.textMuted
                    font.pixelSize: Theme.textXs
                }
            }

            Clickable {
                Layout.preferredWidth: Theme.controlSm
                Layout.preferredHeight: Theme.controlSm
                radius: Theme.radiusFull
                onClicked: Notifications.dismissAll(root.items)

                Icon {
                    anchors.centerIn: parent
                    glyph: "󰅖"
                    size: Theme.iconSm
                }
            }
        }

        // Cards. Collapsed shows only the first; the rest stay out of the tree.
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.gapStack

            Repeater {
                model: ScriptModel {
                    values: root.open || root.items.length < 2 ? root.items : root.items.slice(0, 1)
                }

                NotificationCard {
                    id: card

                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    notification: modelData
                    toast: root.toast
                    showApp: root.toast
                    onClosed: Notifications.dismiss(modelData)
                    onInteractingChanged: root.busy += interacting ? 1 : -1
                    Component.onDestruction: if (interacting)
                        root.busy--
                }
            }
        }

        // Collapsed stack: layers tucked under the card, then "+N more".
        Item {
            id: stack

            visible: root.hidden > 0 && !root.open
            Layout.fillWidth: true
            Layout.topMargin: -Theme.gapStack // hug the card above
            implicitHeight: root.layers * Theme.spaceSm + more.implicitHeight + Theme.spaceXs

            Repeater {
                model: root.layers

                Rectangle {
                    required property int index

                    // Steps down and in, as if cards were stacked behind. Starts
                    // at the card's bottom edge so translucent fills never overlap.
                    x: (index + 1) * Theme.spaceMd
                    y: index * Theme.spaceSm
                    width: stack.width - (index + 1) * Theme.spaceMd * 2
                    height: Theme.spaceSm
                    radius: Theme.radiusSm
                    topLeftRadius: 0
                    topRightRadius: 0
                    color: Theme.tile
                }
            }

            Label {
                id: more

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                text: "+" + root.hidden + " more"
                color: Theme.textMuted
                font.pixelSize: Theme.textXs
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.expandable
                cursorShape: Qt.PointingHandCursor
                onClicked: Notifications.toggleGroup(root.groupKey)
            }
        }
    }

}
