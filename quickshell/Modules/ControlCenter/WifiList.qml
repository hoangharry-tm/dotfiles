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
            spacing: 4

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
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                visible: root.asking === entry.modelData
                implicitHeight: 36
                radius: Theme.radiusSm
                color: Theme.tile
                border.width: 1
                border.color: password.activeFocus ? Theme.primary : Theme.hairline

                TextInput {
                    id: password

                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
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
