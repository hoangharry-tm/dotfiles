import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// Shared frame for expanded lists: title, optional header action, rows.
Section {
    id: root

    property string title: ""
    property string actionGlyph: ""
    property bool actionActive: false
    property string emptyText: ""
    property int count: 0
    default property alias rows: list.data

    signal action

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Theme.spaceMd

        Label {
            Layout.fillWidth: true
            text: root.title
            font.weight: Font.DemiBold
        }

        Clickable {
            visible: root.actionGlyph !== ""
            Layout.preferredWidth: Theme.control
            Layout.preferredHeight: Theme.control
            radius: Theme.radiusFull
            onClicked: root.action()

            Icon {
                anchors.centerIn: parent
                glyph: root.actionGlyph
                color: root.actionActive ? Theme.primary : Theme.textMuted

                RotationAnimation on rotation {
                    running: root.actionActive
                    from: 0
                    to: 360
                    duration: 1400
                    loops: Animation.Infinite
                    onRunningChanged: if (!running)
                        parent.rotation = 0
                }
            }
        }
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: Theme.spaceMd
        visible: root.count === 0 && root.emptyText !== ""
        text: root.emptyText
        color: Theme.textMuted
        font.pixelSize: Theme.textSm
    }

    ColumnLayout {
        id: list

        Layout.fillWidth: true
        spacing: 0
    }
}
