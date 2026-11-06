pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pam

// Lock-screen state and password check. Modules/Lock draws the UI; this owns
// the PAM conversation so every screen's surface shares one attempt.
//
// Auth uses our own pam config (nix: ~/.config/quickshell-pam/lock) that
// loads Arch's pam_unix by absolute path, because Nix's libpam can't verify
// passwords on non-NixOS (its unix_chkpwd helper path doesn't exist here).
Singleton {
    id: root

    property bool locked: false
    // Preview draws the same UI in an ordinary window: no session lock, so
    // it can never strand the user. Real unlock only follows a PAM success.
    property bool preview: false
    property bool busy: false
    property int failures: 0
    property string message: ""
    onLockedChanged: if (!locked) preview = false
    signal failed
    signal unlocked

    function lock() {
        if (!locked) {
            failures = 0;
            message = "";
            locked = true;
        }
    }

    function showPreview() {
        if (!locked) {
            preview = true;
            lock();
        }
    }

    // Held only between submit() and the PAM prompt; cleared right after use.
    property string _pending: ""

    function submit(password) {
        if (busy || password === "")
            return;
        _pending = password;
        busy = true;
        pam.start();
    }

    function _finish(ok) {
        _pending = "";
        busy = false;
        if (ok) {
            // A real password check passed in preview: lock-screen may now
            // trust this path (see modules/theme.nix).
            if (preview)
                Quickshell.execDetached(["sh", "-c", "mkdir -p \"$HOME/.local/state/quickshell\" && : > \"$HOME/.local/state/quickshell/lock-verified\""]);
            locked = false;
            preview = false;
            failures = 0;
            message = "";
            unlocked();
        } else {
            failures++;
            message = message || "Incorrect password";
            failed();
        }
    }

    PamContext {
        id: pam

        configDirectory: Quickshell.env("HOME") + "/.config/quickshell-pam"
        config: "lock"

        onPamMessage: {
            if (responseRequired) {
                respond(root._pending);
                root._pending = "";
            } else if (messageIsError) {
                root.message = message;
            }
        }
        onCompleted: result => root._finish(result === PamResult.Success)
        onError: root._finish(false)
    }
}
