import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Services

// Session lock (ext-session-lock): the compositor hides everything else
// while `locked`, and keeps the session locked even if the shell crashes, so
// only a PAM success may clear it. The preview path draws the same content
// in a plain overlay window and can never lock the session.
//
// Departure is a dissolve, not a cut: when Lock.locked clears, the surfaces
// stay up for Theme.animSlow while LockContent fades its content and blends
// the blurred image into the sharp wallpaper, then the lock is released.
// Auth is untouched: Lock.locked still flips on PAM success only; this scope
// merely delays the compositor-side release by the fade (0 in low power).
Scope {
    id: scope

    // Surfaces exist from lock until the unlock fade has finished.
    property bool shown: false
    property bool leaving: false
    property bool asPreview: false

    IdleGuard {}

    Connections {
        target: Lock

        function onLockedChanged() {
            if (Lock.locked) {
                release.stop();
                scope.leaving = false;
                scope.asPreview = Lock.preview;
                scope.shown = true;
            } else if (scope.shown) {
                scope.leaving = true;
                if (Theme.animSlow > 0)
                    release.restart();
                else
                    scope.shown = false;
            }
        }
    }

    Timer {
        id: release

        interval: Theme.animSlow
        onTriggered: scope.shown = false
    }

    WlSessionLock {
        locked: scope.shown && !scope.asPreview

        WlSessionLockSurface {
            LockContent {
                anchors.fill: parent
                leaving: scope.leaving
                Component.onCompleted: Qt.callLater(focusInput)
            }
        }
    }

    Variants {
        model: scope.shown && scope.asPreview ? Quickshell.screens : []

        PanelWindow {
            required property ShellScreen modelData

            screen: modelData
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.namespace: "qs-lock-preview"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            LockContent {
                anchors.fill: parent
                leaving: scope.leaving
                Component.onCompleted: Qt.callLater(focusInput)
            }
        }
    }
}
