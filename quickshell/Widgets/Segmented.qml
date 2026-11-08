import QtQuick
import qs.Common

// Segmented control: a sliding neutral "on" pill over a recessed well behind equal-width options.
// model: [{ glyph, label, value }]
Surface {
    id: root

    property var model: []
    property var current: null
    readonly property int index: model.findIndex(o => o.value === current)
    readonly property real segment: (width - Theme.spaceXs * 2) / Math.max(1, model.length)

    signal picked(var value)

    implicitHeight: Theme.control + Theme.spaceXs * 2
    variant: "recessed"
    radius: Theme.radiusMd // inner pill radiusSm = radiusMd - spaceXs

    Surface {
        visible: root.index >= 0
        x: Theme.spaceXs + Math.max(0, root.index) * root.segment
        y: Theme.spaceXs
        width: root.segment
        height: Theme.control
        radius: Theme.radiusSm
        variant: "on"

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
                        visible: (seg.modelData.glyph ?? "") !== "" // label-only segments stay centred
                        glyph: seg.modelData.glyph ?? ""
                        color: seg.on ? Theme.text : Theme.textMuted
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: seg.modelData.label
                        color: seg.on ? Theme.text : Theme.textMuted
                        font.pixelSize: Theme.textXs
                        font.weight: Theme.weightEmphasis
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
