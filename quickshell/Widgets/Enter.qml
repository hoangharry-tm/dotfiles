import QtQuick
import qs.Common

// Entrance motion for content INSIDE a glass sheet (the sheet itself must
// never fade/scale, niri draws its blur and shadow): the parent item rises
// enterRise px and fades in on the decelerate curve when `active` turns true.
// `index` staggers list items (capped by Theme.staggerMax, so long lists
// appear together). Runs once per open; nothing runs at idle.
// Usage: Enter { active: root.shown; index: model.index }
Item {
    id: root

    property Item target: parent
    property bool active: false
    property int index: 0

    visible: false

    Translate {
        id: shift
    }

    // High tier only: content also grows from enterScale around its center.
    Scale {
        id: grow

        origin.x: root.target.width / 2
        origin.y: root.target.height / 2
    }

    Component.onCompleted: target.transform = [shift, grow]

    onActiveChanged: {
        if (!active) {
            anim.stop();
            return;
        }
        target.opacity = 0;
        shift.y = Theme.enterRise;
        grow.xScale = grow.yScale = Theme.motionRich ? Theme.enterScale : 1;
        anim.restart();
    }

    SequentialAnimation {
        id: anim

        PauseAnimation {
            duration: Math.min(root.index, Theme.staggerMax) * Theme.stagger
        }

        ParallelAnimation {
            NumberAnimation {
                target: root.target
                property: "opacity"
                to: 1
                duration: Theme.anim
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.curveDecelerate
            }

            NumberAnimation {
                target: grow
                properties: "xScale,yScale"
                to: 1
                duration: Theme.anim
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.curveDecelerate
            }

            NumberAnimation {
                target: shift
                property: "y"
                to: 0
                duration: Theme.anim
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.curveDecelerate
            }
        }
    }
}
