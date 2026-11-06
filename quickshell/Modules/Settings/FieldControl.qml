import QtQuick
import qs.Common
import qs.Widgets

// Single-line text field on a recessed well. Commits on Enter or focus loss,
// and only when the text passes `validator`, so a half-typed value never applies.
Surface {
    id: root

    property string text: ""
    property alias validator: input.validator
    property bool mono: false

    signal committed(string text)

    implicitWidth: Theme.launcherWidth / 4
    implicitHeight: Theme.control
    radius: Theme.radiusSm
    variant: "recessed"

    TextInput {
        id: input

        anchors.fill: parent
        anchors.leftMargin: Theme.padControl
        anchors.rightMargin: Theme.padControl
        verticalAlignment: TextInput.AlignVCenter
        text: root.text
        color: acceptableInput ? Theme.text : Theme.error
        font.family: root.mono ? Theme.mono : Theme.font
        font.pixelSize: Theme.textMd
        selectionColor: Theme.selection
        clip: true
        selectByMouse: true
        onEditingFinished: {
            if (acceptableInput && text !== root.text)
                root.committed(text);
            else
                text = Qt.binding(() => root.text); // drop an invalid edit
        }
    }
}
