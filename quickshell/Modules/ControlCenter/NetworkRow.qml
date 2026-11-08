import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

// One network: its row and, for a secured unknown one, the password prompt.
// `asking` is the network whose prompt is open (shared by the list).
ColumnLayout {
    id: entry

    property var asking: null     // network whose prompt is open (owned by the list)
    required property var modelData

    signal ask(var network)       // request a prompt for it (null closes)

    Layout.fillWidth: true
    spacing: Theme.spaceXs

    ListRow {
        Layout.fillWidth: true
        glyph: Glyphs.signal(entry.modelData.signalStrength)
        title: entry.modelData.name
        subtitle: entry.modelData.connected ? "Connected" : ""
        trailingGlyph: !entry.modelData.connected && Network.secured(entry.modelData) ? "lock" : ""
        marked: entry.modelData.connected
        busy: entry.modelData.stateChanging
        onClicked: {
            const n = entry.modelData;
            if (n.connected)
                return;
            if (n.known || !Network.secured(n))
                n.connect();
            else
                entry.ask(entry.asking === n ? null : n);
        }
        onRightClicked: if (entry.modelData.known)
            entry.modelData.forget()
    }

    Rectangle {
        Layout.fillWidth: true
        visible: entry.asking === entry.modelData
        implicitHeight: Theme.control + Theme.spaceXs
        radius: Theme.radiusSm
        color: Theme.tile
        border.width: password.activeFocus ? Theme.hairlineWidth : 0
        border.color: Theme.textMuted

        Input {
            id: password

            anchors.fill: parent
            anchors.leftMargin: Theme.padControl
            anchors.rightMargin: Theme.padControl
            verticalAlignment: TextInput.AlignVCenter
            echoMode: TextInput.Password
            onVisibleChanged: if (visible) {
                text = "";
                forceActiveFocus();
            }
            onAccepted: {
                entry.modelData.connectWithPsk(text);
                entry.ask(null);
            }
            Keys.onEscapePressed: entry.ask(null)

            Label {
                anchors.verticalCenter: parent.verticalCenter
                visible: password.text === ""
                text: "Password for " + entry.modelData.name
                color: Theme.textMuted
            }
        }
    }
}
