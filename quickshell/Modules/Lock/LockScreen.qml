import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Services

// Session lock (ext-session-lock): the compositor hides everything else
// while `locked`, and keeps the session locked even if the shell crashes, so
// only a PAM success may clear it. The preview path draws the same content
// in a plain overlay window and can never lock the session.
Scope {
    IdleGuard {}

    WlSessionLock {
        locked: Lock.locked && !Lock.preview

        WlSessionLockSurface {
            LockContent {
                anchors.fill: parent
                Component.onCompleted: Qt.callLater(focusInput)
            }
        }
    }

    Variants {
        model: Lock.locked && Lock.preview ? Quickshell.screens : []

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
                Component.onCompleted: Qt.callLater(focusInput)
            }
        }
    }
}
