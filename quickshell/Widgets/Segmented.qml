import QtQuick
import qs.Common

// Segmented control: a sliding accent pill behind equal-width options.
// model: [{ glyph, label, value }]
Rectangle {
    id: root

    property var model: []
    property var current: null
    readonly property int index: model.findIndex(o => o.value === current)
    readonly property real segment: (width - Theme.spaceXs * 2) / Math.max(1, model.length)

    signal picked(var value)

    implicitHeight: Theme.control + Theme.spaceXs * 2
    radius: Theme.radiusMd // inner pill radiusSm = radiusMd - spaceXs
    color: Theme.tile

    Rectangle {
        visible: root.index >= 0
        x: Theme.spaceXs + Math.max(0, root.index) * root.segment
        y: Theme.spaceXs
        width: root.segment
        height: Theme.control
        radius: Theme.radiusSm
        color: Theme.primary

        Behavior on x {
            NumberAnimation {
                duration: Theme.anim
                easing.type: Theme.easing
            }
        }
    }

    Row {
        x: Theme.spaceXs
        y: Theme.spaceXs

        Repeater {
            model: root.model

            Item {
                id: seg

                required property var modelData
                required property int index
                readonly property bool on: index === root.index

                width: root.segment
                height: Theme.control

                Row {
                    anchors.centerIn: parent
                    spacing: Theme.spaceXs

                    Icon {
                        glyph: seg.modelData.glyph
                        color: seg.on ? Theme.primaryText : Theme.textMuted
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: seg.modelData.label
                        color: seg.on ? Theme.primaryText : Theme.textMuted
                        font.pixelSize: Theme.textXs
                        font.weight: Font.DemiBold
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.picked(seg.modelData.value)
                }
            }
        }
    }
}
