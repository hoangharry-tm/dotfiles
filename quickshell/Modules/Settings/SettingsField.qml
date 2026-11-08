import QtQuick
import qs.Common
import qs.Widgets

// Single-line text field on a recessed well, right-aligned like a value.
// Commits on Enter or focus loss, and only when the text passes `validator`,
// so a half-typed value never applies.
Surface {
    id: root

    property string text: ""
    property alias validator: input.validator

    signal committed(string text)

    implicitWidth: Theme.launcherWidth / 4
    implicitHeight: Theme.control
    radius: Theme.radiusSm
    variant: "recessed"

    Input {
        id: input

        anchors.fill: parent
        anchors.leftMargin: Theme.padControl
        anchors.rightMargin: Theme.padControl
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignRight
        text: root.text
        color: acceptableInput ? Theme.text : Theme.error
        selectByMouse: true
        font.features: {
            "tnum": 1
        }
        onEditingFinished: {
            if (acceptableInput && text !== root.text)
                root.committed(text);
            else
                text = Qt.binding(() => root.text); // drop an invalid edit
        }
    }
}
