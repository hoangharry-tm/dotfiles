import QtQuick
import qs.Common

// Smooth wheel scrolling for a Flickable: declare it inside the Flickable
// and set `flick`. It re-parents itself onto the Flickable's viewport (not
// the moving content) and takes wheel events away from Flickable's built-in
// handler; letting both react made notches fight and the list stutter or
// stall. Clicks and hovers pass through (no buttons, no hover).
//
// Two input paths, one frame clock (a FrameAnimation that runs only while
// something is still moving, so idle cost is zero):
//  - Mouse wheel (angleDelta): each notch moves the *target*; contentY chases
//    it with a time-based exponential ease, so a burst of notches stays one
//    continuous glide (restarting a fixed-duration curve per notch made the
//    speed jump on every click, which read as clunky). Notches that arrive
//    close together accelerate a little, like a desktop wheel.
//  - Touchpad (pixelDelta): the finger drives contentY 1:1. libinput gives
//    no momentum to clients, so the release velocity is measured and the
//    content coasts on exponential friction, the way a phone list does.
MouseArea {
    id: root

    required property Flickable flick
    property real step: Theme.rowHeightTall * 2 // px per wheel notch
    readonly property real maxBoost: 1.5        // extra step factor for a fast notch burst
    readonly property int burstMs: 140          // notches closer than this accelerate
    readonly property int idleMs: 70            // no touchpad delta for this long = fingers lifted
    readonly property real minCoast: 120        // px/s: slower releases just stop
    readonly property real stopSpeed: 20        // px/s: coast ends below this

    // 0 idle, 1 glide to target (wheel), 2 coast on release (touchpad)
    property int mode: 0
    property real target: 0
    property real vel: 0
    property double lastPixel: 0
    property double lastNotch: 0

    // True from the first wheel event until the content has settled.
    readonly property bool busy: mode !== 0 || lift.running

    parent: flick
    anchors.fill: parent
    z: 1
    acceptedButtons: Qt.NoButton

    function clamp(y) {
        return Math.max(0, Math.min(y, flick.contentHeight - flick.height));
    }

    function halt() {
        if (mode !== 0)
            flick.contentY = Math.round(flick.contentY); // crisp text once layer-less again
        mode = 0;
        vel = 0;
        frames.stop();
        lift.stop();
    }

    // Fingers left the pad: coast if they were still moving.
    function release() {
        lift.stop();
        if (Math.abs(vel) > minCoast && Theme.animSlow > 0 && Date.now() - lastPixel < idleMs * 3) {
            mode = 2;
            frames.start();
        } else {
            vel = 0;
        }
    }

    onWheel: w => {
        w.accepted = true;
        if (flick.contentHeight <= flick.height)
            return;
        const px = w.pixelDelta.y;
        const ang = w.angleDelta.y;
        if (px === 0 && ang === 0) {
            if (w.phase === Qt.ScrollEnd)
                release();
            return;
        }
        const now = Date.now();
        if (px !== 0) {
            const dy = -px;
            const dt = now - lastPixel;
            frames.stop();
            mode = 0;
            // Smoothed finger speed (px/s); a long gap starts a fresh gesture.
            vel = dt > idleMs * 2 ? 0 : 0.5 * vel + 0.5 * dy / Math.max(dt, 4) * 1000;
            lastPixel = now;
            flick.contentY = clamp(flick.contentY + dy);
            if (w.phase === Qt.ScrollEnd)
                release();
            else
                lift.restart();
        } else {
            lift.stop();
            const boost = 1 + maxBoost * Math.max(0, 1 - (now - lastNotch) / burstMs);
            lastNotch = now;
            // Chain notches: aim from the pending target, not the current y.
            const from = mode === 1 ? target : flick.contentY;
            target = clamp(from - ang / 120 * step * boost);
            vel = 0;
            if (Theme.anim <= 0) {
                mode = 0;
                flick.contentY = target;
            } else {
                mode = 1;
                frames.start();
            }
        }
    }

    // While moving, bake the content into one texture: the renderer then
    // just shifts a quad instead of re-transforming and re-uploading every
    // card's gradient/curve geometry per frame (that was ~25% of a core on
    // the render thread for the Control Center). At rest the live items
    // draw, so text stays sharp and hover/animations are unaffected.
    Binding {
        target: root.flick.contentItem
        property: "layer.enabled"
        value: true
        when: root.busy
    }

    // Some compositors never send the end-of-scroll phase: infer it from silence.
    Timer {
        id: lift

        interval: root.idleMs
        onTriggered: root.release()
    }

    // A drag or fling by other means (mouse drag, keys) takes over.
    Connections {
        target: root.flick

        function onDraggingChanged() {
            if (root.flick.dragging)
                root.halt();
        }
        function onFlickingChanged() {
            if (root.flick.flicking)
                root.halt();
        }
    }

    FrameAnimation {
        id: frames

        onTriggered: {
            const dt = Math.min(frameTime, 0.05); // a stalled frame must not teleport
            const y = root.flick.contentY;
            if (root.mode === 1) {
                const d = root.target - y;
                if (Math.abs(d) < 0.5) {
                    root.flick.contentY = root.target;
                    root.halt();
                } else {
                    root.flick.contentY = y + d * (1 - Math.exp(-dt * 1000 / (Theme.anim / 4)));
                }
            } else {
                const ny = root.clamp(y + root.vel * dt);
                root.flick.contentY = ny;
                root.vel *= Math.exp(-dt * 1000 / Theme.animSlow);
                if (ny <= 0 || ny >= root.flick.contentHeight - root.flick.height || Math.abs(root.vel) < root.stopSpeed)
                    root.halt();
            }
        }
    }
}
