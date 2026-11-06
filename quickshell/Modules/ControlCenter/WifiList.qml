import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// Nearby networks. Tap to join; secured unknown networks ask for the
// password inline. Right-click a saved network to forget it.
DetailList {
    id: root

    property var asking: null       // network waiting for a password

    attached: true
    title: "Wi-Fi"
    actionGlyph: "󰑓"
    actionActive: Network.wifi?.scannerEnabled ?? false
    count: Network.networks.length
    emptyText: Network.wifiEnabled ? "Searching…" : "Wi-Fi is off"
    onAction: Network.setScanning(true)

    Repeater {
        model: Network.networks.slice(0, 10)

        ColumnLayout {
            id: entry

            required property var modelData

            Layout.fillWidth: true
            spacing: Theme.spaceXs

            ListRow {
                Layout.fillWidth: true
                glyph: Network.signalIcon(entry.modelData.signalStrength)
                title: entry.modelData.name
                subtitle: entry.modelData.connected ? "Connected" : entry.modelData.known ? "Saved" : ""
                trailingGlyph: entry.modelData.connected ? "󰄬" : Network.secured(entry.modelData) ? "󰌾" : ""
                selected: entry.modelData.connected
                busy: entry.modelData.stateChanging
                onClicked: {
                    const n = entry.modelData;
                    if (n.connected)
                        return;
                    if (n.known || !Network.secured(n))
                        n.connect();
                    else
                        root.asking = root.asking === n ? null : n;
                }
                onRightClicked: if (entry.modelData.known)
                    entry.modelData.forget()
            }

            // Inline password prompt
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spaceSm
                Layout.rightMargin: Theme.spaceSm
                visible: root.asking === entry.modelData
                implicitHeight: Theme.control + Theme.spaceXs
                radius: Theme.radiusSm
                color: Theme.tile
                border.width: password.activeFocus ? Theme.hairlineWidth : 0
                border.color: Theme.primary

                TextInput {
                    id: password

                    anchors.fill: parent
                    anchors.leftMargin: Theme.spaceMd
                    anchors.rightMargin: Theme.spaceMd
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: Theme.textMd
                    clip: true
                    onVisibleChanged: if (visible) {
                        text = "";
                        forceActiveFocus();
                    }
                    onAccepted: {
                        entry.modelData.connectWithPsk(text);
                        root.asking = null;
                    }
                    Keys.onEscapePressed: root.asking = null

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: password.text === ""
                        text: "Password for " + entry.modelData.name
                        color: Theme.textMuted
                    }
                }
            }
        }
    }
}
