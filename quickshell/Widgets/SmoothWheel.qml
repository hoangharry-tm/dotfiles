import QtQuick
import qs.Common

// Smooth wheel scrolling for a Flickable: declare it inside the Flickable
// and set `flick`. It re-parents itself onto the Flickable's viewport (not
// the moving content) and takes wheel events away from Flickable's built-in
// handler; letting both react made notches fight and the list stutter or
// stall. Clicks and hovers pass through (no buttons, no hover).
// Mouse wheels (angleDelta) glide to the target on a decelerate curve;
// touchpads (pixelDelta) follow the fingers 1:1, since they already stream
// fine-grained deltas and animating them only adds lag.
MouseArea {
    id: root

    required property Flickable flick
    property real step: Theme.rowHeightTall * 1.5 // px per wheel notch

    parent: flick
    anchors.fill: parent
    z: 1
    acceptedButtons: Qt.NoButton

    function clamp(y) {
        return Math.max(0, Math.min(y, flick.contentHeight - flick.height));
    }

    onWheel: w => {
        w.accepted = true;
        if (flick.contentHeight <= flick.height)
            return;
        if (w.pixelDelta.y !== 0) {
            glide.stop();
            flick.contentY = clamp(flick.contentY - w.pixelDelta.y);
        } else {
            // Chain notches: aim from the pending target, not the current y.
            const from = glide.running ? glide.to : flick.contentY;
            glide.to = clamp(from - w.angleDelta.y / 120 * step);
            glide.restart();
        }
    }

    NumberAnimation {
        id: glide

        target: root.flick
        property: "contentY"
        duration: Theme.anim
        easing.type: Easing.OutCubic
    }
}
